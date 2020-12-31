#!/usr/bin/env bash

filepaths=(
  $HOME/Library/KeyBindings/DefaultKeyBinding.dict
)


for filepath in ${filepaths[@]}; do
  cp -va "${filepath}" ./
done

# ./mozc-keymap-custom.txt はmozcの設定から手動でエクスポートする必要がある
