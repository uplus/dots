#!/bin/bash

while read local_ref local_sha1 remote_ref remote_sha1; do
  branch="${remote_ref##refs/heads/}"
  for name in master develop; do
    if [[ "${branch}" = "${name}" ]]; then
      echo "Do not push to ${name} branch!!!"
      exit 1
    fi
  done
done
