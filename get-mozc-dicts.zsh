#!/usr/bin/env zsh

nicoime(){
  wget http://tkido.com/data/nicoime.zip
  unzip -p nicoime.zip nicoime_atok.txt | nkf -Lu --utf8 > nicoime_atok.txt
}

2ch_emoji(){
  wget http://matsucon.net/material/dic/archive/google_std.zip -O 2ch_emoji.zip
  unzip -p 2ch_emoji.zip '*/*_std.txt' | nkf -Lu --utf8 - > 2ch_emoji.txt
}

enhance(){
  wget http://download1650.mediafire.com/bub81g3qvfzg/mmgj0ubmztz/Google日本語入力強化辞書v5.7z -O enhance.7z
  7z x -so enhance.7z 'Google日本語入力強化辞書v5/Google日本語入力強化辞書.txt' | nkf -Lu --utf8 > enhance.txt
}
