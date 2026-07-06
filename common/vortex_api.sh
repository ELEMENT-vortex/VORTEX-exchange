#!/system/bin/sh

VORTEX_ROOT="/sys/kernel/vortex"
VORTEX_V2="/sys/kernel/vortex/v2"
VORTEX_REQUIRED_API="2"
VORTEX_REQUIRED_ABI="2.2"
VORTEX_MODULE_VERSION="4.0.2-neon-api-v2.2-safe"

vortex_read() {
  [ -f "$1" ] && cat "$1" 2>/dev/null
}

vortex_write() {
  NODE="$1"
  VALUE="$2"

  [ -e "$NODE" ] || return 1
  echo "$VALUE" > "$NODE" 2>/dev/null || return 1
  return 0
}

vortex_write_if_exists() {
  NODE="$1"
  VALUE="$2"

  [ -e "$NODE" ] || return 0
  echo "$VALUE" > "$NODE" 2>/dev/null || return 1
  return 0
}

vortex_abi_supported() {
  ABI="$1"

  case "$ABI" in
    2.2|2.3|2.4|2.5|2.6|2.7|2.8|2.9|3|3.*) return 0 ;;
    *) return 1 ;;
  esac
}

vortex_api_present() {
  [ -d "$VORTEX_V2" ] || return 1
  [ -f "$VORTEX_V2/api_version" ] || return 1
  [ "$(cat "$VORTEX_V2/api_version" 2>/dev/null)" = "$VORTEX_REQUIRED_API" ] || return 1
  return 0
}

vortex_api_available() {
  vortex_api_present || return 1

  ABI="$(cat "$VORTEX_V2/abi_version" 2>/dev/null)"
  vortex_abi_supported "$ABI" || return 1

  return 0
}

vortex_profile_id() {
  case "$1" in
    none) echo 0 ;;
    daily) echo 1 ;;
    gaming) echo 2 ;;
    screenoff|sleep) echo 3 ;;
    restore) echo 4 ;;
    *) echo 0 ;;
  esac
}

vortex_set_profile() {
  PROFILE="$1"

  vortex_api_available || return 1
  vortex_write_if_exists "$VORTEX_V2/profile_detail" "${PROFILE}:manual"
  vortex_write_if_exists "$VORTEX_V2/last_command" "profile:${PROFILE}"
  return 0
}

vortex_set_hint() {
  HINT="$1"

  vortex_api_available || return 1
  vortex_write_if_exists "$VORTEX_V2/last_command" "hint:${HINT}"
  return 0
}

vortex_current_profile() {
  vortex_api_present || {
    echo "none"
    return
  }

  DETAIL="$(vortex_read "$VORTEX_V2/profile_detail")"
  [ -n "$DETAIL" ] && echo "$DETAIL" | cut -d: -f1 || echo "none"
}

vortex_current_hint() {
  vortex_api_present || {
    echo "none"
    return
  }

  vortex_read "$VORTEX_V2/last_command"
}

vortex_detect_cpu_policies() {
  VORTEX_LITTLE_POLICY=""
  VORTEX_BIG_POLICY=""
  VORTEX_LITTLE_MAX="999999999"
  VORTEX_BIG_MAX="0"

  for BASE in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$BASE" ] || continue

    PNAME="${BASE##*/}"
    MAX="$(cat "$BASE/cpuinfo_max_freq" 2>/dev/null)"
    [ -z "$MAX" ] && MAX="$(cat "$BASE/scaling_max_freq" 2>/dev/null)"

    case "$MAX" in
      ''|*[!0-9]*) continue ;;
    esac

    if [ "$MAX" -lt "$VORTEX_LITTLE_MAX" ] 2>/dev/null; then
      VORTEX_LITTLE_MAX="$MAX"
      VORTEX_LITTLE_POLICY="$PNAME"
    fi

    if [ "$MAX" -gt "$VORTEX_BIG_MAX" ] 2>/dev/null; then
      VORTEX_BIG_MAX="$MAX"
      VORTEX_BIG_POLICY="$PNAME"
    fi
  done

  [ -z "$VORTEX_LITTLE_POLICY" ] && VORTEX_LITTLE_POLICY="policy0"
  [ -z "$VORTEX_BIG_POLICY" ] && VORTEX_BIG_POLICY="policy6"

  VORTEX_CPU_POLICY_MAP="little=$VORTEX_LITTLE_POLICY,big=$VORTEX_BIG_POLICY,source=runtime"
}

vortex_policy_number() {
  echo "$1" | sed 's/^policy//'
}

vortex_get_little_policy_num() {
  vortex_detect_cpu_policies
  vortex_policy_number "$VORTEX_LITTLE_POLICY"
}

vortex_get_big_policy_num() {
  vortex_detect_cpu_policies
  vortex_policy_number "$VORTEX_BIG_POLICY"
}

vortex_current_io_scheduler() {
  SCHED="$(cat /sys/block/mmcblk0/queue/scheduler 2>/dev/null)"
  CUR="$(echo "$SCHED" | sed -n 's/.*\[\([^]]*\)\].*/\1/p')"
  [ -n "$CUR" ] && echo "$CUR" || echo "unknown"
}

vortex_current_zram_algorithm() {
  ALG="$(cat /sys/block/zram0/comp_algorithm 2>/dev/null)"
  CUR="$(echo "$ALG" | sed -n 's/.*\[\([^]]*\)\].*/\1/p')"
  [ -n "$CUR" ] && echo "$CUR" || echo "unknown"
}

vortex_gpu_path() {
  if [ -d /sys/class/kgsl/kgsl-3d0/devfreq ]; then
    echo "/sys/class/kgsl/kgsl-3d0/devfreq"
  else
    echo "missing"
  fi
}

vortex_gpu_governor() {
  GP="$(vortex_gpu_path)"
  [ "$GP" != "missing" ] && [ -f "$GP/governor" ] && cat "$GP/governor" 2>/dev/null || echo "unknown"
}

vortex_thermal_state() {
  TEMP="$(cat /sys/class/power_supply/battery/temp 2>/dev/null)"

  case "$TEMP" in
    ''|*[!0-9-]*) echo "unknown"; return ;;
  esac

  if [ "$TEMP" -ge 1000 ] 2>/dev/null; then
    HOT=42000
    WARM=38000
  elif [ "$TEMP" -ge 100 ] 2>/dev/null; then
    HOT=420
    WARM=380
  else
    HOT=42
    WARM=38
  fi

  if [ "$TEMP" -ge "$HOT" ] 2>/dev/null; then
    echo "hot"
  elif [ "$TEMP" -ge "$WARM" ] 2>/dev/null; then
    echo "warm"
  else
    echo "normal"
  fi
}

vortex_battery_state() {
  BAT="/sys/class/power_supply/battery"
  CAP="$(cat "$BAT/capacity" 2>/dev/null)"
  STATUS="$(cat "$BAT/status" 2>/dev/null)"

  echo "$STATUS" | grep -qiE "charging|full" && { echo "charging"; return; }

  case "$CAP" in
    ''|*[!0-9]*) echo "unknown"; return ;;
  esac

  if [ "$CAP" -le 15 ] 2>/dev/null; then
    echo "critical"
  elif [ "$CAP" -le 20 ] 2>/dev/null; then
    echo "low"
  else
    echo "normal"
  fi
}

vortex_node_health() {
  CPU="missing"
  GPU="missing"
  IO="missing"
  ZRAM="missing"

  [ -d /sys/devices/system/cpu/cpufreq ] && CPU="ok"
  [ -d /sys/class/kgsl/kgsl-3d0/devfreq ] && GPU="ok"
  [ -f /sys/block/mmcblk0/queue/scheduler ] && IO="ok"
  [ -f /sys/block/zram0/comp_algorithm ] && ZRAM="ok"

  echo "kernel=ok,module=active,cpu=$CPU,gpu=$GPU,io=$IO,zram=$ZRAM"
}

vortex_push_module_state() {
  STATE="$1"
  [ -z "$STATE" ] && STATE="active"

  vortex_api_present || return 1
  vortex_write_if_exists "$VORTEX_V2/module_state" "$STATE"
  vortex_write_if_exists "$VORTEX_V2/module_version" "$VORTEX_MODULE_VERSION"
  vortex_write_if_exists "$VORTEX_V2/kernel_name" "VortexAGNI-1.4-APIv2.2"
  return 0
}

vortex_push_runtime_state() {
  vortex_api_present || return 1

  vortex_detect_cpu_policies
  GP="$(vortex_gpu_path)"
  GG="$(vortex_gpu_governor)"
  IOS="$(vortex_current_io_scheduler)"
  ZALG="$(vortex_current_zram_algorithm)"
  TH="$(vortex_thermal_state)"
  NH="$(vortex_node_health)"

  vortex_write_if_exists "$VORTEX_V2/cpu_policy_map" "$VORTEX_CPU_POLICY_MAP"
  vortex_write_if_exists "$VORTEX_V2/little_policy" "$VORTEX_LITTLE_POLICY"
  vortex_write_if_exists "$VORTEX_V2/big_policy" "$VORTEX_BIG_POLICY"
  vortex_write_if_exists "$VORTEX_V2/gpu_path" "$GP"
  vortex_write_if_exists "$VORTEX_V2/gpu_governor" "$GG"
  vortex_write_if_exists "$VORTEX_V2/io_scheduler_current" "$IOS"
  vortex_write_if_exists "$VORTEX_V2/zram_algorithm" "$ZALG"
  vortex_write_if_exists "$VORTEX_V2/thermal_state" "$TH"
  vortex_write_if_exists "$VORTEX_V2/thermal_level" "$TH"
  case "$TH" in
    hot) THR="low" ;;
    warm) THR="normal" ;;
    *) THR="high" ;;
  esac
  vortex_write_if_exists "$VORTEX_V2/thermal_headroom" "$THR"
  vortex_write_if_exists "$VORTEX_V2/cool_target_temp" "42000"
  vortex_write_if_exists "$VORTEX_V2/node_health" "$NH"
  vortex_push_module_state "active"

  return 0
}

vortex_set_profile_state() {
  PROFILE="$1"
  MODE="$2"
  REASON="$3"

  [ -z "$PROFILE" ] && PROFILE="daily"
  [ -z "$MODE" ] && MODE="balanced"
  [ -z "$REASON" ] && REASON="manual"

  vortex_write_if_exists "$VORTEX_V2/profile_detail" "${PROFILE}:${MODE}"
  vortex_write_if_exists "$VORTEX_V2/profile_reason" "$REASON"
  vortex_write_if_exists "$VORTEX_V2/last_command" "${PROFILE}_${MODE}"
  # Write thermal state first (base state)
  _TH="$(vortex_thermal_state)"
  vortex_write_if_exists "$VORTEX_V2/thermal_level" "$_TH"
  case "$_TH" in
    hot)  _THR="low"    ;;
    warm) _THR="normal" ;;
    *)    _THR="high"   ;;
  esac
  vortex_write_if_exists "$VORTEX_V2/thermal_headroom" "$_THR"

  if [ "$PROFILE" = "gaming" ]; then
    vortex_write_if_exists "$VORTEX_V2/fps_target" "60"
    vortex_write_if_exists "$VORTEX_V2/fps_stability_mode" "performance"
    vortex_write_if_exists "$VORTEX_V2/ui_smoothness_level" "smooth"
    vortex_write_if_exists "$VORTEX_V2/sustain_mode" "performance"
    vortex_write_if_exists "$VORTEX_V2/screen_on_policy" "performance"
  elif [ "$PROFILE" = "screenoff" ] || [ "$PROFILE" = "sleep" ]; then
    vortex_write_if_exists "$VORTEX_V2/battery_saver_level" "1"
    vortex_write_if_exists "$VORTEX_V2/screen_off_policy" "eco"
    vortex_write_if_exists "$VORTEX_V2/sustain_mode" "eco"
    vortex_write_if_exists "$VORTEX_V2/fps_target" "0"
  else
    vortex_write_if_exists "$VORTEX_V2/battery_saver_level" "0"
    vortex_write_if_exists "$VORTEX_V2/screen_on_policy" "balanced"
    vortex_write_if_exists "$VORTEX_V2/sustain_mode" "balanced"
    vortex_write_if_exists "$VORTEX_V2/fps_target" "0"
    vortex_write_if_exists "$VORTEX_V2/fps_stability_mode" "balanced"
    vortex_write_if_exists "$VORTEX_V2/ui_smoothness_level" "balanced"
  fi

  # Note: vortex_push_runtime_state NOT called here to avoid overwriting profile-specific P1 nodes
  return 0
}

vortex_detect_rom_type() {
  MIUI="$(getprop ro.miui.ui.version.name 2>/dev/null)"
  HYPER="$(getprop ro.mi.os.version.name 2>/dev/null)"
  MOD="$(getprop ro.modversion 2>/dev/null)"
  LINEAGE="$(getprop ro.lineage.version 2>/dev/null)"
  CRDROID="$(getprop ro.crdroid.version 2>/dev/null)"
  DISPLAY="$(getprop ro.build.display.id 2>/dev/null)"

  if [ -n "$HYPER" ]; then
    echo 2
    return
  fi

  if [ -n "$MIUI" ]; then
    echo 1
    return
  fi

  if [ -n "$MOD$LINEAGE$CRDROID" ]; then
    echo 0
    return
  fi

  echo "$DISPLAY" | grep -qiE "aosp|lineage|crdroid|project|infinity|pixel|cph[0-9]|rmx[0-9]|oplus|oxygen|realme|oneplus|coloros" && {
    echo 0
    return
  }

  echo 3
}

vortex_prop_first() {
  for P in "$@"; do
    V="$(getprop "$P" 2>/dev/null)"
    [ -n "$V" ] && {
      echo "$V"
      return
    }
  done
}

vortex_port_code() {
  CODE="$(vortex_prop_first \
    ro.build.display.id \
    ro.system.build.display.id \
    ro.vendor.build.display.id \
    ro.build.version.incremental)"
  [ -n "$CODE" ] && echo "$CODE" || echo "Unknown"
}

vortex_port_display_name() {
  MIUI="$(getprop ro.miui.ui.version.name 2>/dev/null)"
  HYPER="$(getprop ro.mi.os.version.name 2>/dev/null)"
  MOD="$(getprop ro.modversion 2>/dev/null)"
  LINEAGE="$(getprop ro.lineage.version 2>/dev/null)"
  CRDROID="$(getprop ro.crdroid.version 2>/dev/null)"
  DISPLAY="$(getprop ro.build.display.id 2>/dev/null)"
  DESC="$(getprop ro.build.description 2>/dev/null)"
  FINGER="$(getprop ro.build.fingerprint 2>/dev/null)"
  BRAND="$(vortex_prop_first ro.product.system.brand ro.product.vendor.brand ro.product.brand ro.product.odm.brand)"
  MANU="$(vortex_prop_first ro.product.manufacturer ro.product.system.manufacturer ro.product.vendor.manufacturer ro.product.odm.manufacturer)"
  MODEL="$(vortex_prop_first ro.product.model ro.product.system.model ro.product.vendor.model ro.product.odm.model)"
  ALL="$DISPLAY $DESC $FINGER $BRAND $MANU $MODEL"

  [ -n "$HYPER" ] && { echo "HyperOS $HYPER"; return; }
  [ -n "$MIUI" ] && { echo "MIUI $MIUI"; return; }
  [ -n "$CRDROID" ] && { echo "crDroid $CRDROID"; return; }
  [ -n "$LINEAGE" ] && { echo "LineageOS $LINEAGE"; return; }
  [ -n "$MOD" ] && { echo "$MOD"; return; }

  echo "$ALL" | grep -qiE "realme|oppo|oplus|oxygen|oneplus|coloros|cph[0-9]|rmx[0-9]|ex01" && {
    echo "OPlus / RealmeUI / OxygenOS Port"
    return
  }

  echo "$DISPLAY" | grep -qiE "project[_ -]?infinity|infinity" && { echo "Project Infinity-X"; return; }
  echo "$DISPLAY" | grep -qiE "pixel|aosp" && { echo "AOSP Port"; return; }

  CODE="$(vortex_port_code)"
  [ "$CODE" != "Unknown" ] && echo "$CODE" || echo "Unknown Port"
}

vortex_port_family_name() {
  T="$(vortex_detect_rom_type)"
  [ "$T" = "1" ] && { echo "MIUI"; return; }
  [ "$T" = "2" ] && { echo "HyperOS"; return; }

  NAME="$(vortex_port_display_name)"
  echo "$NAME" | grep -qiE "OPlus|RealmeUI|OxygenOS|ColorOS" && { echo "OPlusPort"; return; }
  echo "AOSP"
}

vortex_push_rom_hint() {
  vortex_api_present || return 1

  ROM_TYPE="$(vortex_detect_rom_type)"
  vortex_write_if_exists "$VORTEX_V2/last_command" "rom_hint:${ROM_TYPE}"
  return 0
}

vortex_check_compatibility() {
  vortex_api_available || return 1

  COMP="$(vortex_read "$VORTEX_V2/check_compatibility")"
  [ "$COMP" = "1" ] || return 1

  return 0
}
