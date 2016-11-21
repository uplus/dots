#!/usr/bin/env zsh
set -ue
local music_dir rc_file ignore music
export LC_ALL=en_US.UTF-8
music_dir="$HOME/Music"
rc_file="$HOME/.play-music-rc"

filter='percol --match-method=migemo'
# if type migemogrep &>! /dev/null; then
#   filter='peco --initial-filter Migemo'
# else
#   filter='percol --match-method=migemo'
# fi

[[ -f $rc_file ]] && ignore="grep -vif '${rc_file}' |"

music=$(eval "cd '${music_dir}' && find -L -type f | ${ignore} sed 's|^\./||' | ${filter}")

[[ -z $music ]] && exit
vlc --daemon "${music_dir}/${music}" 2>/dev/null
