#!/usr/bin/env zsh

error() {
  echo "error: $1" 1>&2
  exit $2
}

has_git() {
  git -C "$1" rev-parse --git-dir >/dev/null 2>&1
  return $?
}

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
  print_color "skip: ${1#\#}" "${2:-118}"
}

is_comment(){
  [[ $1 =~ ^# ]]
}

action_edit(){
  "${EDITOR}" "${rc_file}"
}

add_rc(){
  #Check duplicate path and add it to rc_file
  if grep -q "^$1" "${rc_file}"; then
    simple "$1 already exists"
  else
    echo $1 >> "${rc_file}"
  fi
}

add_rc_git(){
  local git_path=${*:a}
  #check valid of path
  if ! has_git "${git_path}"; then
    error "$(simple $git_path) is not git repository" 12
  fi

  add_rc "${git_path}"
}
