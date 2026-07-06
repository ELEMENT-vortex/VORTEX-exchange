#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
. "$MODDIR/common/lock.sh"
acquire_lock || exit 1
trap release_lock EXIT
MODE="$1"

case "$MODE" in
  cool|balanced|response|performance) ;;
  extreme) MODE="balanced" ;;
  *) echo "Uso: set_gaming_mode.sh cool|balanced|response|performance"; exit 1 ;;
esac

echo gaming > "$MODDIR/vortex/profile.conf"
echo "$MODE" > "$MODDIR/vortex/gaming_mode.conf"

sh "$MODDIR/common/apply_gaming.sh" "$MODE"
