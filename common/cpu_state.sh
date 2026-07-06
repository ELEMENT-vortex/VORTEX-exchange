#!/system/bin/sh

STATE="/data/adb/vortex_cpu_state.conf"

save_state() {
  {
    for BASE in /sys/devices/system/cpu/cpufreq/policy*; do
      [ -d "$BASE" ] || continue
      p="${BASE##*/policy}"

      echo "policy${p}_gov=$(cat "$BASE/scaling_governor" 2>/dev/null)"
      echo "policy${p}_up=$(cat "$BASE/schedutil/up_rate_limit_us" 2>/dev/null)"
      echo "policy${p}_down=$(cat "$BASE/schedutil/down_rate_limit_us" 2>/dev/null)"
      echo "policy${p}_iowait=$(cat "$BASE/schedutil/iowait_boost_enable" 2>/dev/null)"
      echo "policy${p}_min=$(cat "$BASE/scaling_min_freq" 2>/dev/null)"
      echo "policy${p}_max=$(cat "$BASE/scaling_max_freq" 2>/dev/null)"
    done
  } > "$STATE"
}

restore_state() {
  [ -f "$STATE" ] || return 0
  . "$STATE" 2>/dev/null

  for BASE in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$BASE" ] || continue
    p="${BASE##*/policy}"

    eval GOV="\$policy${p}_gov"
    eval UP="\$policy${p}_up"
    eval DOWN="\$policy${p}_down"
    eval IOWAIT="\$policy${p}_iowait"
    eval MIN="\$policy${p}_min"
    eval MAX="\$policy${p}_max"

    [ -n "$GOV" ] && echo "$GOV" > "$BASE/scaling_governor" 2>/dev/null
    [ -n "$MAX" ] && echo "$MAX" > "$BASE/scaling_max_freq" 2>/dev/null
    [ -n "$MIN" ] && echo "$MIN" > "$BASE/scaling_min_freq" 2>/dev/null
    [ -n "$UP" ] && echo "$UP" > "$BASE/schedutil/up_rate_limit_us" 2>/dev/null
    [ -n "$DOWN" ] && echo "$DOWN" > "$BASE/schedutil/down_rate_limit_us" 2>/dev/null
    [ -n "$IOWAIT" ] && echo "$IOWAIT" > "$BASE/schedutil/iowait_boost_enable" 2>/dev/null
  done
}

case "$1" in
  save) save_state ;;
  restore) restore_state ;;
  *) echo "Uso: cpu_state.sh save|restore" ;;
esac
