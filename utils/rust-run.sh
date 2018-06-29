#!/bin/sh

tmp_exec="$(mktemp)"

rustc "${1}" -O -o "${tmp_exec}"

if [[ $? != 0 ]]; then
  exit
fi

"${tmp_exec}" "${@:2}"
