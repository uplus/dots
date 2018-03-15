#!/usr/bin/env zsh

if [[ ${1:-} = '--sound' ]]; then
  play /usr/share/sounds/Oxygen-Sys-Log-In-Short.ogg >&! /dev/null <&- &!
  shift
fi

message="${1:?message}"
notify-send --urgency=low --icon="${HOME}/.face.icon" --app-name='' "${message}"
