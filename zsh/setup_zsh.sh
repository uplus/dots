#!/bin/sh
local current
current=$(cd `dirname $0` && pwd)

for name in `\ls`; do
	if [[ -f $name ]] && [[ $name != `basename $0` ]]; then
    ln -svi "$current/$name" "$HOME/.$name"
	fi
done

[[ ! -d $HOME/.zsh ]] && mkdir $HOME/.zsh
