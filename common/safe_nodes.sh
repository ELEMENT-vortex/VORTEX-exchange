#!/system/bin/sh

print_safe_nodes() {
  for BASE in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$BASE" ] || continue
    for f in \
      scaling_governor \
      scaling_min_freq \
      schedutil/up_rate_limit_us \
      schedutil/down_rate_limit_us \
      schedutil/iowait_boost_enable
    do
      [ -e "$BASE/$f" ] && echo "$BASE/$f"
    done
  done
}

verify_safe_nodes() {
  echo "===== VORTEX SAFE NODES ====="

  print_safe_nodes | while read -r NODE; do
    [ -z "$NODE" ] && continue

    if [ -e "$NODE" ]; then
      VALUE="$(cat "$NODE" 2>/dev/null)"
      if [ -w "$NODE" ]; then
        echo "OK writable: $NODE = $VALUE"
      else
        echo "OK read-only/user-limited: $NODE = $VALUE"
      fi
    else
      echo "MISSING: $NODE"
    fi
  done
}

case "$1" in
  list) print_safe_nodes ;;
  verify|"") verify_safe_nodes ;;
  *) echo "Uso: safe_nodes.sh list|verify" ;;
esac
