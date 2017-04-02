#!/usr/bin/env zsh
set -u
source helper-chgit

# functions {{{
add_rc(){
  #Check duplicate path and add it to rc_file
  if grep -q "^$1" $rc_file; then
    simple "$1 already exists"
  else
    echo $1 >> $rc_file
  fi
}

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
    [[ $# == 0 ]] && error "please more argument that repository path" 10

    if [[ $* =~ ^% ]]; then
      add_rc "$*"
    else
      local git_path=${*:a}
      #check valid of path
      if ! has_git $git_path; then
        error "$(simple $git_path) is not git repository" 12
      fi

      add_rc "$git_path"
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
  edit) "${EDITOR}" $rc_file ;;
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
