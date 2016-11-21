#!/usr/bin/env zsh
set -ue

if [[ $# -lt 4 ]]; then
  echo "usage: webseri <browser> <url> <start> <last>" 2>/dev/null
  echo "        <url> include {@} to replace the number." 2>/dev/null
  return
fi

browser="${1}"
url="${2}"
start="${3}"
last="${4}"

for i in {"${start}".."${last}"}; do
  eval $browser '${url:gs/{@}/"${i}"/}'
done
