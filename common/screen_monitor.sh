#!/system/bin/sh

MODDIR="/data/adb/modules/vortex_exchange"
PID_FILE="/data/adb/vortex-exchange-monitor.pid"
RUNTIME_BASE="/data/adb/vortex_runtime_base.conf"

CHECK_INTERVAL=30
OFF_DELAY=60
ADAPTIVE_BALANCED_DELAY=300
ADAPTIVE_PLUS_DELAY=1200
ADAPTIVE_DEEP_DELAY=1800

. "$MODDIR/common/utils.sh"
. "$MODDIR/common/screen_state.sh"
. "$MODDIR/common/vortex_api.sh"

if ! sh "$MODDIR/common/check_kernel.sh" >/dev/null 2>&1; then
  logi "Monitor detenido: Vortex API v2 incompatible"
  exit 1
fi

echo "$$" > "$PID_FILE"

save_runtime_base() {
  PROFILE="$(cat "$MODDIR/vortex/profile.conf" 2>/dev/null)"
  DAILY_MODE="$(cat "$MODDIR/vortex/daily_mode.conf" 2>/dev/null)"
  GAMING_MODE="$(cat "$MODDIR/vortex/gaming_mode.conf" 2>/dev/null)"

  [ -z "$PROFILE" ] && PROFILE="daily"
  [ -z "$DAILY_MODE" ] && DAILY_MODE="balanced"
  [ -z "$GAMING_MODE" ] && GAMING_MODE="balanced"

  {
    echo "PROFILE=$PROFILE"
    echo "DAILY_MODE=$DAILY_MODE"
    echo "GAMING_MODE=$GAMING_MODE"
  } > "$RUNTIME_BASE"

  logi "Runtime base saved: profile=$PROFILE daily=$DAILY_MODE gaming=$GAMING_MODE"
}

restore_runtime_base() {
  if [ -f "$RUNTIME_BASE" ]; then
    . "$RUNTIME_BASE" 2>/dev/null
  fi

  [ -z "$PROFILE" ] && PROFILE="$(cat "$MODDIR/vortex/profile.conf" 2>/dev/null)"
  [ -z "$PROFILE" ] && PROFILE="daily"

  sh "$MODDIR/common/cpu_state.sh" restore 2>/dev/null

  case "$PROFILE" in
    gaming)
      MODE="$GAMING_MODE"
      [ -z "$MODE" ] && MODE="$(cat "$MODDIR/vortex/gaming_mode.conf" 2>/dev/null)"
      [ -z "$MODE" ] && MODE="balanced"
      sh "$MODDIR/common/apply_gaming.sh" "$MODE"
      ;;
    daily|*)
      MODE="$DAILY_MODE"
      [ -z "$MODE" ] && MODE="$(cat "$MODDIR/vortex/daily_mode.conf" 2>/dev/null)"
      [ -z "$MODE" ] && MODE="balanced"
      sh "$MODDIR/common/apply_daily.sh" "$MODE"
      ;;
  esac

  logi "Runtime base restored: profile=$PROFILE mode=$MODE"
}

apply_sleep_safe() {
  MODE="$(cat "$MODDIR/vortex/sleep_mode.conf" 2>/dev/null)"
  [ -z "$MODE" ] && MODE="adaptive"

  if [ "$MODE" = "adaptive" ]; then
    PHASE="$1"
    [ -z "$PHASE" ] && PHASE="light"
    sh "$MODDIR/common/apply_sleep.sh" adaptive "$PHASE"
  else
    sh "$MODDIR/common/apply_sleep.sh" "$MODE"
  fi
}

LAST_STATE="unknown"
OFF_START=0
PHASE_APPLIED="none"

logi "Monitor API v2 Base-Persistent Sleep started: PID $$ interval=${CHECK_INTERVAL}s delay=${OFF_DELAY}s adaptive=light${OFF_DELAY}s→balanced${ADAPTIVE_BALANCED_DELAY}s→plus${ADAPTIVE_PLUS_DELAY}s→deep${ADAPTIVE_DEEP_DELAY}s"

while true; do
  STATE="$(screen_state)"
  NOW="$(date +%s)"
  KPROFILE="$(vortex_current_profile)"
  MODE="$(cat "$MODDIR/vortex/sleep_mode.conf" 2>/dev/null)"
  [ -z "$MODE" ] && MODE="adaptive"

  if [ "$STATE" = "on" ]; then
    if [ "$LAST_STATE" != "on" ]; then
      logi "Screen ON detected"
    fi

    if [ "$KPROFILE" = "screenoff" ]; then
      logi "Screen ON: restoring saved base profile"
      restore_runtime_base
    fi

    OFF_START=0
    PHASE_APPLIED="none"
  else
    if [ "$LAST_STATE" != "off" ]; then
      OFF_START="$NOW"
      PHASE_APPLIED="none"
      save_runtime_base
      logi "Screen OFF detected; waiting ${OFF_DELAY}s"
    fi

    OFF_TIME=$((NOW - OFF_START))

    if [ "$MODE" = "adaptive" ]; then
      if [ "$PHASE_APPLIED" = "none" ] && [ "$OFF_TIME" -ge "$OFF_DELAY" ]; then
        logi "Adaptive Sleep phase light after ${OFF_TIME}s"
        apply_sleep_safe "light"
        PHASE_APPLIED="light"
      elif [ "$PHASE_APPLIED" = "light" ] && [ "$OFF_TIME" -ge "$ADAPTIVE_BALANCED_DELAY" ]; then
        logi "Adaptive Sleep phase balanced after ${OFF_TIME}s"
        apply_sleep_safe "balanced"
        PHASE_APPLIED="balanced"
      elif [ "$PHASE_APPLIED" = "balanced" ] && [ "$OFF_TIME" -ge "$ADAPTIVE_PLUS_DELAY" ]; then
        logi "Adaptive Sleep phase plus after ${OFF_TIME}s"
        apply_sleep_safe "plus"
        PHASE_APPLIED="plus"
      elif [ "$PHASE_APPLIED" = "plus" ] && [ "$OFF_TIME" -ge "$ADAPTIVE_DEEP_DELAY" ]; then
        logi "Adaptive Sleep phase deep after ${OFF_TIME}s"
        apply_sleep_safe "deep"
        PHASE_APPLIED="deep"
      fi
    else
      if [ "$PHASE_APPLIED" = "none" ] && [ "$OFF_TIME" -ge "$OFF_DELAY" ]; then
        logi "Fixed Sleep-Safe after ${OFF_TIME}s"
        apply_sleep_safe
        PHASE_APPLIED="fixed"
      fi
    fi
  fi

  LAST_STATE="$STATE"
  sleep "$CHECK_INTERVAL"
done
