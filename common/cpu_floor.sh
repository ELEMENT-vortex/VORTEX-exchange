#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
. "$MODDIR/common/utils.sh"

lowest_freq() {
  POLICY="$1"
  BASE="/sys/devices/system/cpu/cpufreq/policy${POLICY}"

  if [ -f "$BASE/scaling_available_frequencies" ]; then
    cat "$BASE/scaling_available_frequencies" 2>/dev/null | tr ' ' '\n' | grep -E '^[0-9]+$' | sort -n | head -n 1
    return
  fi

  cat "$BASE/cpuinfo_min_freq" 2>/dev/null
}

apply_sleep_floor() {
  for BASE in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$BASE" ] || continue
    p="${BASE##*/policy}"

    LOW="$(lowest_freq "$p")"
    [ -n "$LOW" ] || continue

    write_if_exists "$BASE/scaling_min_freq" "$LOW"
  done
}

case "$1" in
  sleep) apply_sleep_floor ;;
  *) echo "Uso: cpu_floor.sh sleep" ;;
esac
