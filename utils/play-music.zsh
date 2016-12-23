#!/usr/bin/env zsh
set -ue
export LC_ALL=en_US.UTF-8
local -r music_dir="$HOME/Music"
local -r rc_file="$HOME/.play-music-rc"
[[ -f $rc_file ]] && local -r ignore="grep -vif '${rc_file}' |"

local -r filter='percol --match-method=migemo'
# if type migemogrep &>! /dev/null; then
#   filter='peco --initial-filter Migemo'
# else
#   filter='percol --match-method=migemo'
# fi

local -r songs=$(eval "cd '${music_dir}' && find -L -type f | ${ignore:-} sed 's|^\./||' | ${filter}")
[[ -z $songs ]] && exit

vlc --daemon
sleep 0.3
echo "${songs}" | xargs -I{@} vlc "${music_dir}/{@}" 2>/dev/null
