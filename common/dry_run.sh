#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"

PROFILE="$1"
MODE="$2"

[ -z "$PROFILE" ] && PROFILE="$(cat "$MODDIR/vortex/profile.conf" 2>/dev/null)"
[ -z "$MODE" ] && {
  case "$PROFILE" in
    gaming) MODE="$(cat "$MODDIR/vortex/gaming_mode.conf" 2>/dev/null)" ;;
    screenoff) MODE="$(cat "$MODDIR/vortex/sleep_mode.conf" 2>/dev/null)" ;;
    daily|*) MODE="$(cat "$MODDIR/vortex/daily_mode.conf" 2>/dev/null)" ;;
  esac
}

[ -z "$PROFILE" ] && PROFILE="daily"
[ -z "$MODE" ] && MODE="balanced"

echo "===== VORTEX DRY RUN ====="
echo "Profile=$PROFILE"
echo "Mode=$MODE"
echo
echo "Este modo NO aplica cambios. Solo muestra los nodos permitidos."
echo

sh "$MODDIR/common/safe_nodes.sh" verify

echo
echo "===== RULES ====="
echo "Permitido=CPU schedutil dynamic little/big policies"
echo "NoToca=thermal_trips,camera,sensors,charge,network,gpu_write,refresh-rate,vm,io_write"
