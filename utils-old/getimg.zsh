#!/usr/bin/env zsh

if (($# < 3)); then
  echo 'getimg W H name [-p]'
  return
fi

w="${1}"
h="${2}"
name="${3}"
wget "https://unsplash.it/${w}/${h}/?random" -O "${name}"

[[ ${4:-} == '-p' ]] && xdg-open "${name}"
