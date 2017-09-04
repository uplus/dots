#!/usr/bin/env bash

while [[ $PWD != $HOME && ! -f Cargo.toml ]]; do
  cd ..
done

echo "[+] cd ${PWD}"
cargo run
