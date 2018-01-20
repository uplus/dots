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
  push) # {{{
    local count=0
    local push_count=0

    cat "${rc_file}" | while read git_path; do
      if is_comment $git_path; then
        print_comment "${git_path}"
        continue
      fi

      ! has_ahead $git_path && continue
      : $[count+=1]

      git_status_and_cmd "${git_path}" push
      [[ $? == 0 ]] && : $[push_count+=1]
      echo
    done
    echo "$push_count/$count pushed"
    ;; # }}}
  pull) action_pull ;;
  list) action_list ;;
  edit) action_edit ;;
  each) action_each $@ ;;
  shell) action_shell ;;
  help) # {{{
    echo "Usage: ${cmdname} [mode]"
    echo -e "\tdefault subcommand is list"
    echo -e "\tadd PATH or %CMD"
    echo -e "\tpush"
    echo -e "\tpull"
    echo -e "\tlist"
    echo -e "\tedit"
    echo -e "\teach"
    echo -e "\tonly PATTERN"
    echo -e "\tshell"
    echo -e "\thelp"

    ;; # }}}
  *) action_not_subcommand ;;
esac

exit 0
