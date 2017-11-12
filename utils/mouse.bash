#!/usr/bin/env bash

mouse_pos(){
  export $(xdotool getmouselocation --shell | head -2)
}

mouse_move(){
  xdotool mousemove -- $(($X + ${1:-0})) $(($Y + ${2:-0}))
}

mouse_click(){
  xdotool mousedown "${1}"
  xdotool mouseup "${1}"
}

export DISPLAY="${DISPLAY:-:0}"
echo "DISPLAY=${DISPLAY}"

speed_min=4
speed_max="${1:-16}"
speed="${speed_max}"

while read -n 1 -s key; do
  if [[ $key = 's' ]]; then
    if ((speed == speed_max)); then
      speed="${speed_min}"
    else
      speed="${speed_max}"
    fi
    echo "Speed ${speed}"
  fi

  mouse_pos
  case "${key}" in
    'h') let X-="${speed}" ;;
    'j') let Y+="${speed}" ;;
    'k') let Y-="${speed}" ;;
    'l') let X+="${speed}" ;;
    'a'|$'\n') mouse_click 1 ;;
    'q'|';') mouse_click 2 ;;
    'z'|"'") mouse_click 3 ;;
  esac
  mouse_move
done
