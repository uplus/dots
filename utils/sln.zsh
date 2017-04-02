#!/usr/bin/env zsh
if (($# < 2)); then
  warn "usage: sln <source> <target>"
  return 1
else
  ln -svi ${1:a} ${2:a}
fi
