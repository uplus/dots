#!/bin/bash -eu
current="$(cd -- "$(dirname -- "${BASH_SOURCE}")" && pwd)"

ln -svi "$current/zshenv" "$HOME/.zshenv"
ln -svi "$current/zshrc" "$HOME/.zshrc"

[[ ! -d $HOME/.zsh ]] && mkdir -p $HOME/.zsh
[[ ! $SHELL =~ '/zsh' ]] && chsh -s /bin/zsh
