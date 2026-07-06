#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
. "$MODDIR/common/lock.sh"
acquire_lock || exit 1
trap release_lock EXIT
MODE="$1"

case "$MODE" in
  eco|balanced|cool|smart) ;;
  *) echo "Uso: set_daily_mode.sh eco|balanced|cool|smart"; exit 1 ;;
esac

echo daily > "$MODDIR/vortex/profile.conf"
echo "$MODE" > "$MODDIR/vortex/daily_mode.conf"

sh "$MODDIR/common/apply_daily.sh" "$MODE"
