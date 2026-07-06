#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
. "$MODDIR/common/vortex_api.sh"

if ! vortex_api_present; then
  echo "ERROR: Vortex API v2 no disponible. Requiere /sys/kernel/vortex/v2."
  exit 1
fi

API="$(cat /sys/kernel/vortex/v2/api_version 2>/dev/null)"
ABI="$(cat /sys/kernel/vortex/v2/abi_version 2>/dev/null)"
COMP="$(cat /sys/kernel/vortex/v2/check_compatibility 2>/dev/null)"
REASON="$(cat /sys/kernel/vortex/v2/compatibility_reason 2>/dev/null)"

if [ "$API" != "2" ]; then
  echo "ERROR: API incorrecta. v2=$API"
  exit 1
fi

if ! vortex_abi_supported "$ABI"; then
  echo "ERROR: ABI incompatible. Requiere Vortex API v2.2/ABI>=2.2. ABI actual=$ABI"
  exit 1
fi

if [ "$COMP" != "1" ]; then
  echo "ERROR: Kernel no compatible para VORTEX-exchange v4.0.0 API v2.2. Reason=$REASON"
  exit 1
fi

vortex_push_rom_hint >/dev/null 2>&1
vortex_push_runtime_state >/dev/null 2>&1
vortex_push_module_state "active" >/dev/null 2>&1

echo "OK: Vortex API v2.2 compatible ABI=$ABI"
exit 0
