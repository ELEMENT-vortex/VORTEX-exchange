#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
MODE_FILE="$MODDIR/vortex/daily_mode.conf"

. "$MODDIR/common/utils.sh"
. "$MODDIR/common/vortex_api.sh"

MODE="$1"
[ -z "$MODE" ] && MODE="$(cat "$MODE_FILE" 2>/dev/null)"
[ -z "$MODE" ] && MODE="balanced"

case "$MODE" in
  eco|balanced|cool|smart) ;;
  *) MODE="balanced" ;;
esac

sh "$MODDIR/common/detect.sh" --silent >/dev/null 2>&1
. "$MODDIR/common/rom_tuning.sh"

BAT_TEMP="$(cat /sys/class/power_supply/battery/temp 2>/dev/null)"
BAT_CAP="$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)"
REQUESTED_MODE="$MODE"

if [ "$MODE" = "smart" ]; then
  if [ -n "$BAT_TEMP" ] && [ "$BAT_TEMP" -ge 380 ] 2>/dev/null; then
    MODE="cool"
  elif [ -n "$BAT_CAP" ] && [ "$BAT_CAP" -le 20 ] 2>/dev/null; then
    MODE="eco"
  else
    MODE="balanced"
  fi
fi

case "$ROM_FAMILY:$MODE" in
  MIUI:eco)       L_UP=1800; L_DOWN=9000;  B_UP=3200; B_DOWN=14000; IOWAIT=0 ;;
  MIUI:cool)      L_UP=2200; L_DOWN=12000; B_UP=4000; B_DOWN=18000; IOWAIT=0 ;;
  MIUI:balanced)  L_UP=1400; L_DOWN=7000;  B_UP=2600; B_DOWN=11000; IOWAIT=0 ;;

  HyperOS:eco)      L_UP=2000; L_DOWN=10000; B_UP=3600; B_DOWN=16000; IOWAIT=0 ;;
  HyperOS:cool)     L_UP=2400; L_DOWN=13000; B_UP=4400; B_DOWN=20000; IOWAIT=0 ;;
  HyperOS:balanced) L_UP=1600; L_DOWN=8000;  B_UP=3000; B_DOWN=13000; IOWAIT=0 ;;

  *:eco)       L_UP=1700; L_DOWN=8500;  B_UP=3000; B_DOWN=13000; IOWAIT=0 ;;
  *:cool)      L_UP=2100; L_DOWN=11000; B_UP=3800; B_DOWN=17000; IOWAIT=0 ;;
  *)           L_UP=1300; L_DOWN=6500;  B_UP=2400; B_DOWN=10000; IOWAIT=0 ;;
esac

vortex_push_runtime_state >/dev/null 2>&1
L_POLICY="$(vortex_get_little_policy_num)"
B_POLICY="$(vortex_get_big_policy_num)"

vortex_set_profile_state "daily" "$MODE" "daily:$REQUESTED_MODE rom=$ROM_FAMILY temp=$BAT_TEMP" >/dev/null 2>&1

write_cpu_schedutil "$L_POLICY" "$L_UP" "$L_DOWN" "$IOWAIT"
write_cpu_schedutil "$B_POLICY" "$B_UP" "$B_DOWN" "$IOWAIT"

logi "Daily $MODE APIv2.2 applied: little=policy$L_POLICY $L_UP/$L_DOWN big=policy$B_POLICY $B_UP/$B_DOWN iowait=$IOWAIT requested=$REQUESTED_MODE"
echo "Daily $MODE aplicado"
