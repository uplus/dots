#!/usr/bin/env bash

filepaths=(
  $HOME/Library/KeyBindings/DefaultKeyBinding.dict
)


for filepath in ${filepaths[@]}; do
  cp -va "${filepath}" ./
done
