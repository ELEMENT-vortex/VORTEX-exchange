#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
MODE="$1"

. "$MODDIR/common/lock.sh"
acquire_lock || exit 1
trap release_lock EXIT

. "$MODDIR/common/screen_state.sh"

case "$MODE" in
  light|balanced|plus|deep|adaptive) ;;
  *) echo "Uso: set_sleep_mode.sh light|balanced|plus|deep|adaptive"; exit 1 ;;
esac

echo "$MODE" > "$MODDIR/vortex/sleep_mode.conf"

if is_screen_on; then
  echo "Sleep-Safe $MODE guardado. Se aplicará cuando la pantalla se apague."
else
  sh "$MODDIR/common/apply_sleep.sh" "$MODE"
fi
