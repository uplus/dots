#!/usr/bin/env zsh

if [[ $# -lt 2 ]]; then
  echo "<remote host> <port> [other args]"
  exit 1
fi

remote_host="${1}"
bind_port="${2}"
shift 2

ssh -f -N -L "${bind_port}:127.0.0.1:${bind_port}" "${remote_host}" ${@}

# listen_port="${1:? local listen port}"
# target_host="${2:? target host from footstool}"
# target_port="${3:? target port}"
# footstool_host="${4:? footstool host}"
# shift 4
# ssh -f -N -L "${listen_port}:${target_host}:${target_port}" "${footstool_host}" ${@}
