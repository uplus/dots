#!/usr/bin/env zsh

root="${1}"
shift

while [[ $PWD != $HOME && ! -e $root ]]; do
  cd ..
done

echo "[+] cd ${PWD}"
${@}
