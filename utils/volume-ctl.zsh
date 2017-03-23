#!/usr/bin/env zsh

sinks(){
  pactl list sinks | grep -E '^Sink|^\s*(Name|Mute|Volume):'
}

players(){
  pactl list sink-inputs | grep -E '^Sink Input|^\s*(Sink|Mute|Volume):|^\s*application\.(name|icon_name|process\.binary)|^$'
}

players-compact(){
  players | grep -oP '(?<=Sink Input #)([0-9]+)|(?<=Sink: )[0-9]+|(?<=application.name = ).*' | sed 'N;N;s/\n/ /g'
}

set-volume(){
  pactl set-sink-volume "${1:?index}" "${2:?volume}%"
}

set-player-volume(){
  pactl set-sink-input-volume "${1:?index}" "${2:?volume}%"
}

set-player-sink(){
  pactl move-sink-input "${1:?player index}" "${2:?sink index}"
}

set-players-sink(){
  sink="${1:?sink index}"
  shift
  players-compact | grep -iE "$(echo "${*}" | sed "s/ /|/g")" | awk '$0=$1' |
    while read i; do
      set-player-sink "${i}" "${sink}"
    done
}

get-default-sink(){
  pactl list sinks short | grep "$(pactl info | grep -Po '(?<=Default Sink\:\s).*')"
}

get-default-sink-index(){
  get-default-sink | awk '{print $1}'
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
