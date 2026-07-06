#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
SLEEP_FILE="$MODDIR/vortex/sleep_mode.conf"

. "$MODDIR/common/utils.sh"
. "$MODDIR/common/vortex_api.sh"
. "$MODDIR/common/screen_state.sh"

if is_screen_on; then
  logi "Sleep-Safe blocked: screen is ON"
  echo "Sleep-Safe no aplicado: pantalla encendida."
  exit 0
fi

MODE="$1"
[ -z "$MODE" ] && MODE="$(cat "$SLEEP_FILE" 2>/dev/null)"
[ -z "$MODE" ] && MODE="adaptive"

case "$MODE" in
  light|balanced|plus|deep|adaptive) ;;
  *) MODE="adaptive" ;;
esac

REQUESTED_MODE="$MODE"
PHASE="$2"
[ "$MODE" = "adaptive" ] && [ -n "$PHASE" ] && MODE="$PHASE"

# up_rate_limit_us  : alto = lento en SUBIR freq (ahorra batería en sleep)
# down_rate_limit_us: bajo  = rápido en BAJAR freq (ahorra batería en sleep)
case "$MODE" in
  light)
    L_UP=3500; L_DOWN=5000; B_UP=5000; B_DOWN=7000 ;;
  balanced)
    L_UP=5500; L_DOWN=4000; B_UP=7500; B_DOWN=5500 ;;
  plus)
    L_UP=8000; L_DOWN=3000; B_UP=11000; B_DOWN=4000 ;;
  deep)
    L_UP=11000; L_DOWN=2500; B_UP=14000; B_DOWN=3000 ;;
esac

vortex_push_runtime_state >/dev/null 2>&1
L_POLICY="$(vortex_get_little_policy_num)"
B_POLICY="$(vortex_get_big_policy_num)"

vortex_set_profile_state "screenoff" "$MODE" "sleep:$REQUESTED_MODE phase=$MODE screen=off" >/dev/null 2>&1
vortex_set_hint "sleep_$MODE" >/dev/null 2>&1

sh "$MODDIR/common/cpu_floor.sh" sleep >/dev/null 2>&1

write_cpu_schedutil "$L_POLICY" "$L_UP" "$L_DOWN" "0"
write_cpu_schedutil "$B_POLICY" "$B_UP" "$B_DOWN" "0"

logi "Sleep-Safe $MODE APIv2.2 applied: little=policy$L_POLICY up=$L_UP down=$L_DOWN big=policy$B_POLICY up=$B_UP down=$B_DOWN cpu_floor=on requested=$REQUESTED_MODE"
echo "Sleep-Safe $MODE APIv2.2 aplicado"
