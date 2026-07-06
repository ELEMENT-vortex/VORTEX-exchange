#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
MODE_FILE="$MODDIR/vortex/gaming_mode.conf"

. "$MODDIR/common/utils.sh"
. "$MODDIR/common/vortex_api.sh"

MODE="$1"
[ -z "$MODE" ] && MODE="$(cat "$MODE_FILE" 2>/dev/null)"
[ -z "$MODE" ] && MODE="balanced"

case "$MODE" in
  cool|balanced|response|performance) ;;
  extreme)
    MODE="balanced"
    echo balanced > "$MODE_FILE"
    logi "Modo gaming no permitido; fallback balanced"
    ;;
  *) MODE="balanced" ;;
esac

sh "$MODDIR/common/detect.sh" --silent >/dev/null 2>&1
. "$MODDIR/common/rom_tuning.sh"

case "$ROM_FAMILY:$MODE" in
  MIUI:cool)        L_UP=1500; L_DOWN=8000; B_UP=1800; B_DOWN=12000; IOWAIT=0 ;;
  MIUI:response)    L_UP=900;  L_DOWN=5000; B_UP=1000; B_DOWN=7000;  IOWAIT=1 ;;
  MIUI:performance) L_UP=800;  L_DOWN=5500; B_UP=900;  B_DOWN=8500;  IOWAIT=1 ;;
  MIUI:balanced)    L_UP=1100; L_DOWN=6000; B_UP=1300; B_DOWN=9000;  IOWAIT=1 ;;

  HyperOS:cool)        L_UP=1700; L_DOWN=9000; B_UP=2000; B_DOWN=14000; IOWAIT=0 ;;
  HyperOS:response)    L_UP=1000; L_DOWN=5500; B_UP=1100; B_DOWN=8000;  IOWAIT=1 ;;
  HyperOS:performance) L_UP=900;  L_DOWN=6000; B_UP=1000; B_DOWN=9500;  IOWAIT=1 ;;
  HyperOS:balanced)    L_UP=1200; L_DOWN=6500; B_UP=1400; B_DOWN=10000; IOWAIT=1 ;;

  *:cool)        L_UP=1400; L_DOWN=7500; B_UP=1700; B_DOWN=11000; IOWAIT=0 ;;
  *:response)    L_UP=800;  L_DOWN=4500; B_UP=900;  B_DOWN=6500;  IOWAIT=1 ;;
  *:performance) L_UP=700;  L_DOWN=5000; B_UP=800;  B_DOWN=8000;  IOWAIT=1 ;;
  *)             L_UP=1000; L_DOWN=5500; B_UP=1200; B_DOWN=8000;  IOWAIT=1 ;;
esac

vortex_push_runtime_state >/dev/null 2>&1
L_POLICY="$(vortex_get_little_policy_num)"
B_POLICY="$(vortex_get_big_policy_num)"

vortex_set_profile_state "gaming" "$MODE" "gaming:$MODE rom=$ROM_FAMILY target=60fps" >/dev/null 2>&1

write_cpu_schedutil "$L_POLICY" "$L_UP" "$L_DOWN" "$IOWAIT"
write_cpu_schedutil "$B_POLICY" "$B_UP" "$B_DOWN" "$IOWAIT"

logi "Gaming $MODE APIv2.2 applied: little=policy$L_POLICY $L_UP/$L_DOWN big=policy$B_POLICY $B_UP/$B_DOWN iowait=$IOWAIT target=60fps"
echo "Gaming $MODE aplicado"
