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
    simple_color $1
    git -C $1 status --short --branch
    git -C $1 pull --ff-only
    echo
    ;;
  esac
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
echo "Load ${rc_file}"

local mode="${1:=list}"
shift
case $mode in
  add) # {{{
    [[ $# == 0 ]] && error "Please repository path or cmd" 10

    if [[ $* =~ ^% ]]; then
      add_rc "${*}"
    else
      add_rc_git ${@}
    fi
    ;; # }}}
  pull) # {{{
    while read line; do
      execute "$line"
    done < $rc_file
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
    while read line; do
      case "${line}" in
        \#*) print_comment "${line}" ;;
        %*) echo $(echo "${line}" | sed s/^%//) ;;
        *) simple_color "${line}" ;;
      esac
    done < $rc_file
    ;; # }}}
  edit) action_edit ;;
  help) # {{{
    echo "Usage: chrepo [mode]"
    echo -e "\tnon-argument show list"
    echo -e "\tadd PATH or %CMD"
    echo -e "\tpull"
    echo -e "\tonly PATTERN"
    echo -e "\tlist"
    echo -e "\tedit"
    echo -e "\thelp"
    ;; # }}}
  *) error "wrong $mode is not option" 60 ;;
esac

exit 0
