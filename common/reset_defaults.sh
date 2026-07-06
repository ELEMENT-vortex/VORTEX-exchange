#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
. "$MODDIR/common/lock.sh"
acquire_lock || exit 1
trap release_lock EXIT

echo daily > "$MODDIR/vortex/profile.conf"
echo balanced > "$MODDIR/vortex/daily_mode.conf"
echo balanced > "$MODDIR/vortex/gaming_mode.conf"
echo adaptive > "$MODDIR/vortex/sleep_mode.conf"
echo normal > "$MODDIR/vortex/thermal_mode.conf"

sh "$MODDIR/common/apply_daily.sh" balanced

echo "Valores por defecto restaurados: Daily Balanced / Gaming Balanced / Sleep Adaptive / Thermal Normal"
