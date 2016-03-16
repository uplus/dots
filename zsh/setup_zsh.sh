#!/bin/bash -eu
current="$(cd -- "$(dirname -- "${BASH_SOURCE}")" && pwd)"
for name in $(\ls -F $current/ | egrep -v ".*/|.*\*|README\..*"); do
  ln -svi "$current/$name" "$HOME/.$name"
done

[[ ! -d $HOME/.zsh ]] && mkdir $HOME/.zsh

os_local_file="$HOME/.zsh.$(uname | tr '[:upper]' '[:lower]')"

case $OSTYPE in
linux*)
  rm_file=darwin
  ;;
darwin*)
  rm_file=linux
  ;;
esac

[[ -L $HOME/.zshrc.$rm_file ]] && rm $HOME/.zshrc.$rm_file

[[ ! $SHELL =~ '/zsh' ]] && chsh -s /bin/zsh
