#!/bin/sh

for name in `\ls`; do
	if [[ -f $name ]] && [[ $name != `basename $0` ]]; then
		ln -svi "$PWD/$name" "$HOME/.$name"
	fi
done

[[ ! -d $HOME/.zsh ]] && mkdir $HOME/.zsh
