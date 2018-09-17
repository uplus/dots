#!/usr/bin/env zsh

countdown(){
  for i in {${1:-5}..1}; do
    echo -n "${i} "
    sleep 1
  done
  echo -n 0
}

set_base_pos(){
  eval "$(xdotool getwindowgeometry --shell "${LINE_WID}")"
  export BASE_X=$X
  export BASE_Y=$Y
  export BASE_WIDTH=$WIDTH
  export BASE_HEIGHT=$HEIGHT
}

open_stamp(){
  set_base_pos
  xdotool mousemove $(($BASE_X+$BASE_WIDTH-90)) $(($BASE_Y+$BASE_HEIGHT-30))
  xdotool click --window $LINE_WID 1
}

# record to file.
choose_stamp(){
  open_stamp
  echo 'Point stamp to send.'
  countdown 5
  echo -ne ".\n"

  # record
  eval $(xdotool getmouselocation --shell)
  echo STAMP_X=$(($X-$BASE_X)) STAMP_Y=$(($Y-$BASE_Y)) | tee ~/.send_stamp

  # close
  open_stamp
}

send_stamp(){
  sleep "${STAMP_INTERVAL}"
  open_stamp

  sleep "${STAMP_INTERVAL}"
  xdotool mousemove "$(($BASE_X+$1))" "$(($BASE_Y+$2))"
  xdotool click --window $LINE_WID 1
}

help(){
  echo 'Usage:'
  echo 'set         Select stamp to send.'
  echo 'send <NUM>  Send stamp NUM times.'
}

export LINE_WID="$(xdotool search --name LINE)"
if [[ -z $LINE_WID ]]; then
  echo "LINE window not found."
  exit
fi

if [[ -z ${STAMP_INTERVAL:-} ]]; then
  export STAMP_INTERVAL=0.35
fi

if [[ $1 == 'set' ]]; then
  choose_stamp
elif [[ $1 == 'send' && $# -eq 2 ]]; then
  # set stamp point.
  eval $(cat ~/.send_stamp)

  cat ~/.send_stamp
  echo
  read '?Enter! '

  for i in {1..${2}}; do
    send_stamp $STAMP_X $STAMP_Y
  done
else
  help
fi
