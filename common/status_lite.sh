#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
. "$MODDIR/common/vortex_api.sh"

PROFILE="$(cat "$MODDIR/vortex/profile.conf" 2>/dev/null)"
DAILY_MODE="$(cat "$MODDIR/vortex/daily_mode.conf" 2>/dev/null)"
GAMING_MODE="$(cat "$MODDIR/vortex/gaming_mode.conf" 2>/dev/null)"
SLEEP_MODE="$(cat "$MODDIR/vortex/sleep_mode.conf" 2>/dev/null)"
THERMAL_MODE="$(cat "$MODDIR/vortex/thermal_mode.conf" 2>/dev/null)"

[ -z "$PROFILE" ] && PROFILE="daily"
[ -z "$DAILY_MODE" ] && DAILY_MODE="balanced"
[ -z "$GAMING_MODE" ] && GAMING_MODE="balanced"
[ -z "$SLEEP_MODE" ] && SLEEP_MODE="adaptive"
[ -z "$THERMAL_MODE" ] && THERMAL_MODE="normal"

echo "PerfilBase=$PROFILE"
echo "DailyMode=$DAILY_MODE"
echo "GamingMode=$GAMING_MODE"
echo "SleepMode=$SLEEP_MODE"
echo "ThermalMode=$THERMAL_MODE"

echo "Kernel=$(uname -r)"

if vortex_api_available; then
  ABI_NOW="$(cat /sys/kernel/vortex/v2/abi_version 2>/dev/null)"
  echo "VortexAPI=v2.2"
  echo "KernelName=$(cat /sys/kernel/vortex/v2/kernel_name 2>/dev/null)"
  echo "KernelVersion=$(cat /sys/kernel/vortex/v2/kernel_version 2>/dev/null)"
  echo "Device=$(cat /sys/kernel/vortex/v2/device 2>/dev/null)"
  echo "V2APIVersion=$(cat /sys/kernel/vortex/v2/api_version 2>/dev/null)"
  echo "ABI=$(cat /sys/kernel/vortex/v2/abi_version 2>/dev/null)"
  echo "APIState=$(cat /sys/kernel/vortex/v2/api_state 2>/dev/null)"
  echo "CheckCompatibility=$(cat /sys/kernel/vortex/v2/check_compatibility 2>/dev/null)"
  echo "CompatibilityCode=$(cat /sys/kernel/vortex/v2/compatibility_code 2>/dev/null)"
  echo "CompatibilityReason=$(cat /sys/kernel/vortex/v2/compatibility_reason 2>/dev/null)"
  echo "KernelProfile=$(cat /sys/kernel/vortex/v2/profile_detail 2>/dev/null | cut -d: -f1)"
  echo "KernelHint=$(cat /sys/kernel/vortex/v2/last_command 2>/dev/null)"
  echo "LastCommand=$(cat /sys/kernel/vortex/v2/last_command 2>/dev/null)"
  echo "LastError=$(cat /sys/kernel/vortex/v2/last_error 2>/dev/null)"
  echo "ProfileDetail=$(cat /sys/kernel/vortex/v2/profile_detail 2>/dev/null)"
  echo "ProfileReason=$(cat /sys/kernel/vortex/v2/profile_reason 2>/dev/null)"
  echo "CpuPolicyMap=$(cat /sys/kernel/vortex/v2/cpu_policy_map 2>/dev/null)"
  echo "LittlePolicy=$(cat /sys/kernel/vortex/v2/little_policy 2>/dev/null)"
  echo "BigPolicy=$(cat /sys/kernel/vortex/v2/big_policy 2>/dev/null)"
  echo "GpuPath=$(cat /sys/kernel/vortex/v2/gpu_path 2>/dev/null)"
  echo "GpuGovernor=$(cat /sys/kernel/vortex/v2/gpu_governor 2>/dev/null)"
  echo "IoSchedulerCurrent=$(cat /sys/kernel/vortex/v2/io_scheduler_current 2>/dev/null)"
  echo "ZramAlgorithm=$(cat /sys/kernel/vortex/v2/zram_algorithm 2>/dev/null)"
  echo "ThermalState=$(cat /sys/kernel/vortex/v2/thermal_state 2>/dev/null)"
  echo "FpsTarget=$(cat /sys/kernel/vortex/v2/fps_target 2>/dev/null)"
  echo "ThermalLevel=$(cat /sys/kernel/vortex/v2/thermal_level 2>/dev/null)"
  echo "ThermalHeadroom=$(cat /sys/kernel/vortex/v2/thermal_headroom 2>/dev/null)"
  echo "UISmoothnessLevel=$(cat /sys/kernel/vortex/v2/ui_smoothness_level 2>/dev/null)"
  echo "UIBoostMs=$(cat /sys/kernel/vortex/v2/ui_boost_ms 2>/dev/null)"
  echo "FpsStabilityMode=$(cat /sys/kernel/vortex/v2/fps_stability_mode 2>/dev/null)"
  echo "SustainMode=$(cat /sys/kernel/vortex/v2/sustain_mode 2>/dev/null)"
  echo "BatterySaverLevel=$(cat /sys/kernel/vortex/v2/battery_saver_level 2>/dev/null)"
  echo "ScreenOnPolicy=$(cat /sys/kernel/vortex/v2/screen_on_policy 2>/dev/null)"
  echo "ScreenOffPolicy=$(cat /sys/kernel/vortex/v2/screen_off_policy 2>/dev/null)"
  echo "NodeHealth=$(cat /sys/kernel/vortex/v2/node_health 2>/dev/null)"
  echo "ModuleState=$(cat /sys/kernel/vortex/v2/module_state 2>/dev/null)"
  echo "ModuleVersion=$(cat /sys/kernel/vortex/v2/module_version 2>/dev/null)"
  echo "API=OK"
else
  echo "VortexAPI=missing"
  echo "API=FAIL"
fi

ROM_NAME="$(vortex_port_display_name)"
ROM_CODE="$(vortex_port_code)"
ROM_FAMILY="$(vortex_port_family_name)"

# ROM es amigable para WebUI. ROMCode conserva el código real del port/build.
echo "ROM=$ROM_NAME"
echo "ROMName=$ROM_NAME"
echo "ROMCode=$ROM_CODE"
echo "Familia=$ROM_FAMILY"
echo "Android=$(getprop ro.build.version.release 2>/dev/null)"
echo "SDK=$(getprop ro.build.version.sdk 2>/dev/null)"


for BASE in /sys/devices/system/cpu/cpufreq/policy*; do
  [ -d "$BASE" ] || continue
  p="${BASE##*/policy}"
  [ -d "$BASE" ] || continue

  echo "policy${p}_gov=$(cat "$BASE/scaling_governor" 2>/dev/null)"
  echo "policy${p}_up=$(cat "$BASE/schedutil/up_rate_limit_us" 2>/dev/null)"
  echo "policy${p}_down=$(cat "$BASE/schedutil/down_rate_limit_us" 2>/dev/null)"
  echo "policy${p}_iowait=$(cat "$BASE/schedutil/iowait_boost_enable" 2>/dev/null)"
  echo "policy${p}_min=$(cat "$BASE/scaling_min_freq" 2>/dev/null)"
  echo "policy${p}_max=$(cat "$BASE/scaling_max_freq" 2>/dev/null)"
done

echo "NoToca=thermal_trips,camera,sensors,charging,network,gpu_write,refresh_rate,vm,io_write"
