#!/usr/bin/env zsh
set -u

#config
local rc_file="$HOME/.chgitrc"
local git_path
local -a g_status
g_status=(status --short --branch)

# functions {{{
error() {
  echo "error: $1" 1>&2
  exit $2
}

has_git() {
  git -C "$1" rev-parse --git-dir >/dev/null 2>&1
  return $?
}

has_rc() { return $([[ -f $rc_file ]]) }

simple() {
  echo $@ | sed -e "s|^$HOME|~|g"
}

print_color(){
  echo -e "\e[38;5;${2:-1}m$1\e[00m"
}

simple_color() {
  1=$(printf "%-30s" $(simple $1))
  print_color "${1}" 39
}

print_comment(){
  print_color "skip: ${1#\#}" 3
}

has_ahead() {
  [[ -n $(git -C $1 $g_status | head -1 | grep -oe "\[.*]$") ]]
}

is_comment(){
  [[ $1 =~ ^# ]]
}

check_repos() {
  local st

  cat "${rc_file}" | while read git_path; do
    if is_comment $git_path; then
      print_comment "${git_path}" 3
      continue
    fi

    st=$(git -C $git_path -c color.status=always $g_status)
    echo "$(simple_color $git_path) $st"
    [[ -n $(echo $st | sed -e 1d) ]] && echo
  done
}
# }}}

#Start
! has_rc && touch $rc_file

local mode=${1:-}
shift 2>/dev/null
case "${mode}" in
  '') check_repos ;;
  add) # {{{
    [[ $# == 0 ]] && error "please more argument that repository path" 10
    git_path=${*:a}

    #check valid of path
    if ! has_git $git_path; then
      error "$(simple $git_path) is not git repository" 12
    fi

    #Check duplicate path and add it to rc_file
    if grep -q "^$git_path" $rc_file; then
      simple "$git_path already exists"
    else
      echo $git_path >> $rc_file
    fi
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
  list)
    cat "${rc_file}" | while read git_path; do
      simple $git_path
    done
    ;;
  edit) "${EDITOR}" $rc_file ;;
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
