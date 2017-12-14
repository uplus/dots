#!/usr/bin/env zsh

#TODO: rubyとかで作りなおしたほうがいいかも
#マッチした部分のon/off
#特定ディレクトリの無視、検索条件指定
#errorの表示 on/off

if [ $# -lt 1 ]; then
  echo "findstr [DIR] [OPTS] STR" 1>&2
  return 1
fi

local location str opt

if [[ $# -eq 1 ]]; then
  location="."
else
  location=$1
  shift
fi

while [ $# -gt 1 ]; do
  opt="$opt $1"
  shift
done

str=$1

# echo "location: $location"
# echo "opt: $opt"
# echo "str: $str"

find "${location}" ${opt} -type f -exec grep --color=auto -iIH "${str}" {} \; 2> /dev/null
