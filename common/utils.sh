#!/system/bin/sh

LOG="/data/adb/vortex-exchange.log"
MAX_LOG_SIZE=65536

rotate_log() {
  [ -f "$LOG" ] || return 0
  SIZE="$(wc -c < "$LOG" 2>/dev/null)"
  [ -z "$SIZE" ] && return 0

  if [ "$SIZE" -gt "$MAX_LOG_SIZE" ]; then
    tail -n 120 "$LOG" > "$LOG.tmp" 2>/dev/null
    mv "$LOG.tmp" "$LOG" 2>/dev/null
    echo "[VORTEX-exchange] Log rotated" >> "$LOG"
  fi
}

logi() {
  rotate_log
  echo "[VORTEX-exchange] $*" >> "$LOG"
}

readf() {
  cat "$1" 2>/dev/null
}

write_if_exists() {
  NODE="$1"
  VALUE="$2"

  [ -e "$NODE" ] || return 1

  CUR="$(cat "$NODE" 2>/dev/null)"
  [ "$CUR" = "$VALUE" ] && return 0

  if echo "$VALUE" > "$NODE" 2>/dev/null; then
    logi "WRITE OK: $NODE = $VALUE"
    return 0
  else
    logi "WRITE FAIL: $NODE = $VALUE"
    return 1
  fi
}

write_cpu_schedutil() {
  POLICY="$1"
  UP="$2"
  DOWN="$3"
  IOWAIT="$4"

  BASE="/sys/devices/system/cpu/cpufreq/policy${POLICY}"

  [ -d "$BASE" ] || return 1

  write_if_exists "$BASE/scaling_governor" "schedutil"
  write_if_exists "$BASE/schedutil/up_rate_limit_us" "$UP"
  write_if_exists "$BASE/schedutil/down_rate_limit_us" "$DOWN"
  write_if_exists "$BASE/schedutil/iowait_boost_enable" "$IOWAIT"

  return 0
}
