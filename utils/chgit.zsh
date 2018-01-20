#!/usr/bin/env zsh
set -u

source helper-chgit
local cmdname="${0:t:r}"

#Start
local rc_file="$(find_rc "${cmdname}")"

if [[ $rc_file != $HOME/.${cmdname}rc ]]; then
  print_color "[+] Load ${rc_file}" 220
fi

local mode="${1:-list}"
shift 2>/dev/null

case "${mode}" in
  add) action_add "${@}" ;;
  push) action_push ;;
  pull) action_pull ;;
  only) action_only "${1}" ;;
  list) action_list ;;
  edit) action_edit ;;
  each) action_each $@ ;;
  shell) action_shell ;;
  help) action_help ;;
  *) action_not_subcommand ;;
esac

exit 0
