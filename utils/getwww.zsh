#!/usr/bin/env zsh

webnum 'wget -O file-$i.pdf' "${1}" "${2}" "${3}"
pdfjoin -o "${PWD:t}.pdf" file-*
