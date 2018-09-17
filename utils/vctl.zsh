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
  find-players-index ${*:?names} | awk '{print $1}'|
    while read i; do
      set-player-sink "${i}" "${sink}"
    done
}

rotate-players-sink(){
  tmp="$(find-players-index ${*:?names})"
  now="$(echo "${tmp}" | awk 'NR<2{print $2}')"

  ply_i=${(z)$(echo "${tmp}" | awk '{print $1}' | tr '\n' ' ')}
  snk_i=${(z)$(get-sinks-index)}

  now_pos="${snk_i[(i)${now}]}"
  next_pos="$((${now_pos}+1))"
  (($#snk_i < next_pos)) &&  next_pos=1

  for i in ${ply_i}; do
    set-player-sink "${i}" "${snk_i[next_pos]}"
  done
}

find-players-index(){
  players-compact | grep -iE "$(echo "${*}" | sed "s/ /|/g")" | awk '{print $1" "$2}'
}

get-sinks-index(){
  pactl list sinks short | awk '{print $1}'
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

alias rotate=rotate-players-sink

if [[ $# -eq 0 ]]; then
  cat $0 | grep -o '^[^) ]*)'
else
  eval $@
fi
