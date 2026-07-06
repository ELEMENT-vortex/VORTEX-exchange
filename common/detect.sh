#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
OUT="/data/adb/vortex_detect.conf"

[ -f "$MODDIR/common/vortex_api.sh" ] && . "$MODDIR/common/vortex_api.sh"

if command -v vortex_port_display_name >/dev/null 2>&1; then
  ROM="$(vortex_port_display_name)"
  ROM_CODE="$(vortex_port_code)"
  FAMILY="$(vortex_port_family_name)"
else
  ROM="$(getprop ro.modversion)"
  [ -z "$ROM" ] && ROM="$(getprop ro.lineage.version)"
  [ -z "$ROM" ] && ROM="$(getprop ro.crdroid.version)"
  [ -z "$ROM" ] && ROM="$(getprop ro.build.display.id)"
  [ -z "$ROM" ] && ROM="Unknown"
  ROM_CODE="$(getprop ro.build.display.id)"
  FAMILY="AOSP"
fi

DEVICE="$(getprop ro.product.device)"
ANDROID="$(getprop ro.build.version.release)"
SDK="$(getprop ro.build.version.sdk)"

cat > "$OUT" <<EOF2
ROM_NAME="$ROM"
ROM_CODE="$ROM_CODE"
ROM_FAMILY="$FAMILY"
DEVICE="$DEVICE"
ANDROID="$ANDROID"
SDK="$SDK"
EOF2

[ "$1" = "--silent" ] || cat "$OUT"
