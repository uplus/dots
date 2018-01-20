#!/usr/bin/env zsh
set -u
source helper-chgit

# functions {{{
execute() {
  case "${1}" in
    \#*) print_comment "${1}" ;;
    %*)
      print_color "${1}" 2
      zsh -ic "eval $(echo "${1#%}")" </dev/tty
      ;;
    *)
      git_status_and_cmd "${1}" pull --ff-only
      echo
      ;;
  esac
}

list() {
  cat "${rc_file}" | while read line; do
  case "${line}" in
    \#*) print_comment "${line}" ;;
    %*) echo $(echo "${line}" | sed s/^%//) ;;
    *) simple_color "${line}" ;;
  esac
done
}
# }}}

#Start
local rc_file="$(
  while [[ $PWD != $HOME && ! -f $PWD/.chreporc ]]; do
    cd ..
    [[ $PWD == $OLDPWD ]] && cd
  done
  echo "${PWD}"
)/.chreporc"
if [[ $rc_file == $HOME/.chreporc ]]; then
  echo "Load ${rc_file}"
else
  print_color "Load ${rc_file}" 220
fi

local mode="${1:-list}"
shift 2>/dev/null
case $mode in
  add) # {{{
    [[ $# == 0 ]] && error "Please git repository path or cmd" 10

    if [[ $* =~ ^% ]]; then
      add_rc "${*}"
    else
      add_rc_git ${@}
    fi
    ;; # }}}
  pull) # {{{
    cat "${rc_file}" | while read line; do
      execute "$line"
    done
    ;; # }}}
  only) # {{{
    : "${1:?the only option need <PATTERN>}"
    matched=$(grep "${1}" "$rc_file" | head -1)
    [[ -z $matched ]] && error "not matched: ${1}" 20

    read -k key"?$matched (Y/n)"
    [[ $key != $'\n' ]] && echo
    if [[ ! $key =~ [nN] ]]; then
      execute "$matched"
    fi
    ;; # }}}
  list) # {{{
    list
    ;; # }}}
  edit) action_edit ;;
  each) action_each $@ ;;
  shell) action_shell ;;
  help) # {{{
    echo "Usage: ${0:t:r} [mode]"
    echo -e "\tnon-argument show list"
    echo -e "\tadd PATH or %CMD"
    echo -e "\tpull"
    echo -e "\tonly PATTERN"
    echo -e "\tlist"
    echo -e "\tedit"
    echo -e "\teach"
    echo -e "\tshell"
    echo -e "\thelp"
    ;; # }}}
  *) error "wrong $mode is not option" 60 ;;
esac

exit 0
