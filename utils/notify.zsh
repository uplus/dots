#!/usr/bin/env zsh

message="${1:?message}"
notify-send --urgency=low --icon="${HOME}/.face.icon" --app-name='' "${message}"
play /usr/share/sounds/Oxygen-Sys-Log-In-Short.ogg >&! /dev/null <&- &!
