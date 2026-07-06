#!/system/bin/sh

MODDIR=${0%/*}
LOG="/data/adb/vortex-exchange.log"
PID_FILE="/data/adb/vortex-exchange-monitor.pid"

sleep 20

echo "===== VORTEX-exchange v4.0.2 API v2.2 boot =====" > "$LOG"

if [ -f "$PID_FILE" ]; then
  OLD_PID="$(cat "$PID_FILE" 2>/dev/null)"
  [ -n "$OLD_PID" ] && kill "$OLD_PID" 2>/dev/null
  rm -f "$PID_FILE"
fi

if ! sh "$MODDIR/common/check_kernel.sh" >/dev/null 2>&1; then
  echo "[VORTEX-exchange] Kernel/API v2.2 incompatible: $(uname -r)" >> "$LOG"
  exit 1
fi

. "$MODDIR/common/vortex_api.sh"

mkdir -p "$MODDIR/vortex"

[ -f "$MODDIR/vortex/profile.conf" ] || echo daily > "$MODDIR/vortex/profile.conf"
[ -f "$MODDIR/vortex/daily_mode.conf" ] || echo balanced > "$MODDIR/vortex/daily_mode.conf"
[ -f "$MODDIR/vortex/gaming_mode.conf" ] || echo balanced > "$MODDIR/vortex/gaming_mode.conf"
[ -f "$MODDIR/vortex/sleep_mode.conf" ] || echo adaptive > "$MODDIR/vortex/sleep_mode.conf"

GM="$(cat "$MODDIR/vortex/gaming_mode.conf" 2>/dev/null)"
[ "$GM" = "extreme" ] && echo balanced > "$MODDIR/vortex/gaming_mode.conf"
echo normal > "$MODDIR/vortex/thermal_mode.conf"

vortex_push_module_state "booting" >/dev/null 2>&1
vortex_push_runtime_state >/dev/null 2>&1

sh "$MODDIR/common/cpu_state.sh" save 2>/dev/null

PROFILE="$(cat "$MODDIR/vortex/profile.conf" 2>/dev/null)"
[ -z "$PROFILE" ] && PROFILE="daily"

case "$PROFILE" in
  gaming) sh "$MODDIR/common/set_profile.sh" gaming ;;
  daily|*) sh "$MODDIR/common/set_profile.sh" daily ;;
esac

vortex_push_module_state "active" >/dev/null 2>&1

echo "[VORTEX-exchange] Boot apply done: $PROFILE" >> "$LOG"

nohup sh "$MODDIR/common/screen_monitor.sh" >/dev/null 2>&1 &
