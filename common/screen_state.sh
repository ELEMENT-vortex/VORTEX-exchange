#!/system/bin/sh

screen_state() {
  # Primero sysfs: rápido y liviano.
  if [ -f /sys/class/backlight/panel0-backlight/bl_power ]; then
    BL="$(cat /sys/class/backlight/panel0-backlight/bl_power 2>/dev/null)"
    BR="$(cat /sys/class/backlight/panel0-backlight/brightness 2>/dev/null)"

    if [ "$BL" = "0" ] && [ -n "$BR" ] && [ "$BR" -gt 0 ] 2>/dev/null; then
      echo "on"
      return
    fi

    if [ "$BR" = "0" ] 2>/dev/null; then
      echo "off"
      return
    fi
  fi

  # Fallback por dumpsys, usado solo si sysfs no es concluyente.
  DS="$(dumpsys display 2>/dev/null | grep -m1 -E "Display State=|mState=|state ")"

  echo "$DS" | grep -q "ON" && {
    echo "on"
    return
  }

  echo "$DS" | grep -q "OFF" && {
    echo "off"
    return
  }

  PW="$(dumpsys power 2>/dev/null | grep -m1 "mWakefulness=")"
  echo "$PW" | grep -q "Awake" && echo "on" || echo "off"
}

is_screen_on() {
  [ "$(screen_state)" = "on" ]
}

# Si se ejecuta directamente, imprime el estado.
if [ "$(basename "$0")" = "screen_state.sh" ]; then
  screen_state
fi
