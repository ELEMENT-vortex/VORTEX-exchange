#!/system/bin/sh

CONF="/data/adb/vortex_detect.conf"
[ -f "$CONF" ] && . "$CONF"

[ -z "$ROM_FAMILY" ] && ROM_FAMILY="AOSP"
[ -z "$SDK" ] && SDK="$(getprop ro.build.version.sdk)"

# En Android 15/16 se mantiene conservador para no pelear con PowerHAL/ThermalHAL.
if [ "$SDK" -ge 35 ] 2>/dev/null; then
  TUNING_CLASS="android15plus_safe"
else
  TUNING_CLASS="legacy_safe"
fi
