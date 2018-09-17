#!/usr/bin/env zsh
set -ue

[[ $# -ne 0 ]] && pushd $1

count=0
for f in *(.); do
  mv -v $(printf "${f}\t\t%03d.%s\n" "${count}" "${f:e}")
  let count+=1
done

[[ $# != 0 ]] && popd
