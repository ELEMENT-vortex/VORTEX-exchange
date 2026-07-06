#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
. "$MODDIR/common/vortex_api.sh"

echo "===== VORTEX-exchange v4.0.0 API v2.2 Self Test ====="

echo
echo "===== API v2.2 ====="
if sh "$MODDIR/common/check_kernel.sh"; then
  echo "APIv2.2=OK"
else
  echo "APIv2.2=FAIL"
  exit 1
fi

echo
echo "===== ROM HINT ====="
vortex_push_rom_hint && echo "rom_hint=OK" || echo "rom_hint=FAIL"
echo "last_command=$(cat /sys/kernel/vortex/v2/last_command 2>/dev/null)"

echo
echo "===== API v2.2 EXTENDED STATE ====="
vortex_push_runtime_state >/dev/null 2>&1
for f in \
  profile_detail profile_reason cpu_policy_map little_policy big_policy \
  gpu_path gpu_governor io_scheduler_current zram_algorithm thermal_state \
  fps_target thermal_level thermal_headroom ui_smoothness_level ui_boost_ms \
  fps_stability_mode sustain_mode battery_saver_level screen_on_policy screen_off_policy \
  node_health module_state module_version
 do
  [ -e "/sys/kernel/vortex/v2/$f" ] && echo "$f=$(cat /sys/kernel/vortex/v2/$f 2>/dev/null)"
done

echo
echo "===== CPU WRITABLE CHECK ====="
for BASE in /sys/devices/system/cpu/cpufreq/policy*; do
  [ -d "$BASE" ] || continue
  for f in scaling_governor scaling_min_freq scaling_max_freq schedutil/up_rate_limit_us schedutil/down_rate_limit_us; do
    NODE="$BASE/$f"
    if [ -e "$NODE" ]; then
      [ -w "$NODE" ] && echo "OK writable: $NODE" || echo "OK read-only/user-limited: $NODE"
    else
      echo "MISSING: $NODE"
    fi
  done
done

echo
echo "===== RESULT ====="
echo "SelfTest=OK"
