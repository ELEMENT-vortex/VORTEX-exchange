#!/system/bin/sh

LOCKDIR="/data/adb/vortex-exchange.lock"
LOCK_TIMEOUT=8

acquire_lock() {
  i=0

  while ! mkdir "$LOCKDIR" 2>/dev/null; do
    OLD_PID="$(cat "$LOCKDIR/pid" 2>/dev/null)"

    if [ -n "$OLD_PID" ] && ! kill -0 "$OLD_PID" 2>/dev/null; then
      rm -rf "$LOCKDIR" 2>/dev/null
      continue
    fi

    i=$((i + 1))
    [ "$i" -ge "$LOCK_TIMEOUT" ] && {
      echo "VORTEX ocupado. Intenta otra vez."
      return 1
    }

    sleep 1
  done

  echo "$$" > "$LOCKDIR/pid"
  return 0
}

release_lock() {
  rm -rf "$LOCKDIR" 2>/dev/null
}
