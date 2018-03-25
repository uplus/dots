#!/usr/bin/env bash
current="$(cd -- "$(dirname -- "${0}")" && pwd)"

niconico(){
  wget http://tkido.com/data/nicoime.zip -O niconico
  unzip -p niconico.zip nicoime_atok.txt | nkf -Lu --utf8 > niconico.txt
}

emoji(){
  wget http://matsucon.net/material/dic/archive/google_std.zip -O emoji.zip
  unzip -p emoji.zip '*/*_std.txt' | nkf -Lu --utf8 - > emoji.txt
}

enhance(){
  wget http://download1650.mediafire.com/bub81g3qvfzg/mmgj0ubmztz/Google日本語入力強化辞書v5.7z -O enhance.7z
  7z x -so enhance.7z 'Google日本語入力強化辞書v5/Google日本語入力強化辞書.txt' | nkf -Lu --utf8 > enhance.txt
}

help(){
  grep -o "^[^ ]*()" "${current}/get-mozc-dicts.sh" | sed "s/()//g"
}

if [ $# -eq 0 ]; then
  help
else
  $1
fi
