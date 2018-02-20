#!/bin/sh

keyboard_enable() {
  keyboard="${1:-ErgoDox}"
  mode="${2:-enable}"
  xinput --list | grep "${keyboard}" | grep -Po '(?<=id=)\d+' | xargs -I@ xinput "--${mode}" @
}

ergodox_connecting() {
  xinput --list 2>/dev/null | grep -q ErgoDox
}

if [[ -n "${DISPLAY:-}" && -f $HOME/.Xmodmap ]]; then
  if ergodox_connecting; then
    keyboard_enable 'ErgoDox' enable
    keyboard_enable 'Apple Internal Keyboard' disable
    setxkbmap -layout us
  else
    keyboard_enable 'ErgoDox' disable
    keyboard_enable 'Apple Internal Keyboard' enable

    if [[ -n "${DISPLAY:-}" && -f $HOME/.Xmodmap ]]; then
      xmodmap ~/.Xmodmap
    fi
  fi
fi
