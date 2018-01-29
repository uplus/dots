#!/usr/bin/env zsh

if (($# < 2)); then
  echo "usage: sln <source> <target>" >&2
  return 1
else
  ln -svi ${1:a} ${2:a}
fi
