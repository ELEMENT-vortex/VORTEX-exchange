#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
OUT="/sdcard/VORTEX-exchange-v4.0.2-api-v2.2-report.txt"

{
  echo "===== VORTEX-exchange REPORT ====="
  date
  echo

  echo "===== MODULE ====="
  cat "$MODDIR/module.prop" 2>/dev/null
  echo

  echo "===== STATUS LITE ====="
  sh "$MODDIR/common/status_lite.sh" 2>/dev/null
  echo

  echo "===== VORTEX SYSFS — ls /sys/kernel/vortex/v2/ ====="
  ls -la /sys/kernel/vortex/v2/ 2>/dev/null || echo "DIRECTORIO NO EXISTE"
  echo

  echo "===== VORTEX API v2.2 RAW — SAFE NODES ====="
  for f in \
    /sys/kernel/vortex/v2/api_version \
    /sys/kernel/vortex/v2/abi_version \
    /sys/kernel/vortex/v2/api_state \
    /sys/kernel/vortex/v2/check_compatibility \
    /sys/kernel/vortex/v2/compatibility_code \
    /sys/kernel/vortex/v2/compatibility_reason \
    /sys/kernel/vortex/v2/kernel_name \
    /sys/kernel/vortex/v2/device \
    /sys/kernel/vortex/v2/node_health \
    /sys/kernel/vortex/v2/module_state \
    /sys/kernel/vortex/v2/module_version \
    /sys/kernel/vortex/v2/profile_detail \
    /sys/kernel/vortex/v2/profile_reason \
    /sys/kernel/vortex/v2/last_command \
    /sys/kernel/vortex/v2/last_error
  do
    [ -e "$f" ] && echo "  ${f##*/}=$(cat "$f" 2>/dev/null)"
  done
  echo

  echo "===== VORTEX API v2.2 RAW — P1 NODES ====="
  for f in \
    /sys/kernel/vortex/v2/cool_target_temp \
    /sys/kernel/vortex/v2/thermal_level \
    /sys/kernel/vortex/v2/thermal_headroom \
    /sys/kernel/vortex/v2/ui_smoothness_level \
    /sys/kernel/vortex/v2/ui_boost_ms \
    /sys/kernel/vortex/v2/fps_target \
    /sys/kernel/vortex/v2/fps_stability_mode \
    /sys/kernel/vortex/v2/sustain_mode \
    /sys/kernel/vortex/v2/battery_saver_level \
    /sys/kernel/vortex/v2/screen_on_policy \
    /sys/kernel/vortex/v2/screen_off_policy
  do
    if [ -e "$f" ]; then
      VAL="$(cat "$f" 2>/dev/null)"
      [ -z "$VAL" ] && VAL="(empty)" 
      echo "  ${f##*/}=$VAL"
    else
      echo "  ${f##*/}=MISSING"
    fi
  done
  echo

  echo "===== CPU STATE ====="
  for BASE in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$BASE" ] || continue
    p="${BASE##*/policy}"
    echo "--- policy$p ---"
    for f in scaling_governor scaling_min_freq scaling_max_freq schedutil/up_rate_limit_us schedutil/down_rate_limit_us schedutil/iowait_boost_enable; do
      [ -e "$BASE/$f" ] && echo "$f=$(cat "$BASE/$f" 2>/dev/null)"
    done
  done
  echo

  echo "===== SCREEN STATE ====="
  sh "$MODDIR/common/screen_state.sh" 2>/dev/null
  echo

  echo "===== DUMPSYS POWER SHORT ====="
  dumpsys power 2>/dev/null | grep -E "mWakefulness|Display Power|Wake Locks|mWakeLockSummary|Doze|mHolding" | head -n 80
  echo

  echo "===== LOG TAIL ====="
  tail -n 160 /data/adb/vortex-exchange.log 2>/dev/null
  echo

  echo "===== NOTE ====="
  echo "VORTEX-exchange v4.0.2 API v2.2. No toca thermal trips, camara, sensores, carga, red, GPU write, refresh-rate, VM ni IO write."
} > "$OUT"

echo "$OUT"
