#!/usr/bin/env zsh

listen_port="${1:? local listen port}"
target_host="${2:? target host from footstool}"
target_port="${3:? target port}"
footstool_host="${4:? footstool host}"
shift 4

ssh -f -N -L "${listen_port}:${target_host}:${target_port}" "${footstool_host}" ${@}
