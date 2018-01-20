#!/usr/bin/env zsh
set -u
source helper-chgit
local cmdname="${0:t:r}"

# functions {{{
list() {
  local st

  cat "${rc_file}" | while read git_path; do
    if is_comment "${git_path}"; then
      print_comment "${git_path}"
      continue
    elif [[ ! -d $git_path ]]; then
      print_comment "${git_path}" 220
      continue
    fi

    st=$(git -C $git_path -c color.status=always $g_status)
    git_path="$(short_path ${git_path} 30)"
    echo "$(simple_color $git_path) $st"
    [[ -n $(echo $st | sed -e 1d) ]] && echo
  done
}
# }}}

#Start
local rc_file="$HOME/.${cmdname}rc"
[[ ! -f $rc_file ]] && touch $rc_file

local mode="${1:-list}"
shift 2>/dev/null

case "${mode}" in
  add) # {{{
    action_add "${@}"
    ;; # }}}
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
  pull) # {{{
    local count=0
    local push_count=0

    cat "${rc_file}" | while read git_path; do
      : $[count+=1]

      if is_comment $git_path; then
        print_comment "${git_path}"
        continue
      fi

      git_status_and_cmd "${git_path}" pull --ff-only
      [[ $? == 0 ]] && : $[push_count+=1]
      echo
    done

    echo "$push_count/$count pulled"
    ;; # }}}
  list) # {{{
    list
    ;; # }}}
  edit) action_edit ;;
  each) action_each $@ ;;
  shell) action_shell ;;
  help) # {{{
    echo "Usage: ${cmdname} [mode]"
    echo -e "\tnon-argument check status of git repositories"
    echo -e "\tadd PATH"
    echo -e "\tpush"
    echo -e "\tpull"
    echo -e "\tlist"
    echo -e "\tedit"
    echo -e "\teach"
    echo -e "\tshell"
    echo -e "\thelp"
    ;; # }}}
  *) action_not_subcommand ;;
esac

exit 0
