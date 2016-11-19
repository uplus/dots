#!/usr/bin/env zsh

sinks(){
  pactl list sinks | grep -E '^Sink|^\s*(Name|Mute|Volume):'
}

players(){
  pactl list sink-inputs | grep -E '^Sink Input|^\s*(Sink|Mute|Volume):|^\s*application\.(name|icon_name|process\.binary)|^$'
}

set-volume(){
  pactl set-sink-volume "${1:?index}" "${2:?volume}%"
}

set-player-volume(){
  pactl set-sink-input-volume "${1:?index}" "${2:?volume}%"
}

get-default-sink(){
  pactl list sinks short | grep "$(pactl info | grep -Po '(?<=Default Sink\:\s).*')"
}

get-default-sink-index(){
  pactl list sinks short | grep "$(pactl info | grep -Po '(?<=Default Sink\:\s).*')" | awk '{print $1}'
}

info(){
  echo "###Sinks"
  sinks
  echo -e "\n\n###Players(sink-input)"
  players
}


# TODO:
if [[ $# -eq 0 ]]; then
  cat $0
else
  $@
fi
