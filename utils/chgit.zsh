#!/usr/bin/env zsh
set -u
source helper-chgit

#config
local rc_file="$HOME/.chgitrc"
local git_path
local -a g_status
g_status=(status --short --branch)

# functions {{{
has_ahead() {
  [[ -n $(git -C $1 $g_status | head -1 | grep -oe "\[.*]$") ]]
}

check_repos() {
  local st

  cat "${rc_file}" | while read git_path; do
    if is_comment "${git_path}"; then
      print_comment "${git_path}" 118
      continue
    elif [[ ! -d $git_path ]]; then
      print_comment "${git_path}" 220
      continue
    fi

    st=$(git -C $git_path -c color.status=always $g_status)
    echo "$(simple_color $git_path) $st"
    [[ -n $(echo $st | sed -e 1d) ]] && echo
  done
}
# }}}

#Start
[[ ! -f $rc_file ]] && touch $rc_file

local mode=${1:-}
shift 2>/dev/null
case "${mode}" in
  '') check_repos ;;
  add) # {{{
    [[ $# == 0 ]] && error "Please repository path" 10
    add_rc_git ${@}
    ;; # }}}
  push) # {{{
    local count=0
    local push_count=0

    cat "${rc_file}" | while read git_path; do
      if is_comment $git_path; then
        print_comment "${git_path}" 3
        continue
      fi
      ! has_ahead $git_path && continue
      : $[count+=1]
      simple_color $git_path
      git -C $git_path $g_status
      git -C $git_path push
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
        print_comment "${git_path}" 3
        continue
      fi

      simple_color $git_path
      git -C $git_path $g_status
      git -C $git_path pull --ff-only
      [[ $? == 0 ]] && : $[push_count+=1]
      echo
    done

    echo "$push_count/$count pulled"
    ;; # }}}
  list) # {{{
    cat "${rc_file}" | while read git_path; do
      simple $git_path
    done
    ;; # }}}
  edit) action_edit ;;
  each) # {{{
    for git_path in $(cat $rc_file); do
      simple_color $git_path
      local str="$(git -C $git_path -c color.status=always status --short)"
      # [[ -z $str ]] && continue
      echo -e "$str"
      git -C $git_path $@
      echo
    done
    ;; # }}}
  help) # {{{
    echo "Usage: chgit [mode]"
    echo -e "\tnon-argument check status of git repositories"
    echo -e "\tadd PATH"
    echo -e "\tpush"
    echo -e "\tpull"
    echo -e "\tlist"
    echo -e "\tedit"
    echo -e "\teach"
    echo -e "\thelp"
    ;; # }}}
  *) error "wrong $mode is not option" 60 ;;
esac

exit 0
