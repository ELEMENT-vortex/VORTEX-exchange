#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"

if ! sh "$MODDIR/common/check_kernel.sh" >/dev/null 2>&1; then
  echo "Kernel/API incompatible."
  exit 1
fi

PROFILE="$1"

case "$PROFILE" in
  daily)
    MODE="$(cat "$MODDIR/vortex/daily_mode.conf" 2>/dev/null)"
    [ -z "$MODE" ] && MODE="balanced"
    sh "$MODDIR/common/set_daily_mode.sh" "$MODE"
    ;;
  gaming)
    MODE="$(cat "$MODDIR/vortex/gaming_mode.conf" 2>/dev/null)"
    [ -z "$MODE" ] && MODE="balanced"
    [ "$MODE" = "extreme" ] && MODE="balanced"
    sh "$MODDIR/common/set_gaming_mode.sh" "$MODE"
    ;;
  screenoff)
    MODE="$(cat "$MODDIR/vortex/sleep_mode.conf" 2>/dev/null)"
    [ -z "$MODE" ] && MODE="balanced"
    sh "$MODDIR/common/apply_sleep.sh" "$MODE"
    ;;
  *)
    echo "Uso: set_profile.sh daily|gaming|screenoff"
    exit 1
    ;;
esac
