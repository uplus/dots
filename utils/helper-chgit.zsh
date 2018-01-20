#!/usr/bin/env zsh

typeset -a g_status
g_status=(status --short --branch)

find_rc() {
  cmdname="${1:?command name}"

  filepath="$(
  while [[ $PWD != $HOME && ! -f $PWD/.${cmdname}rc ]]; do
    cd ..
    [[ $PWD == $OLDPWD ]] && cd
  done
  echo "${PWD}"
  )/.${cmdname}rc"

  # ~/ にも無いなら生成
  [[ ! -f $filepath ]] && touch $filepath

  echo "${filepath}"
}

error() {
  echo "[!] $1" 1>&2
  exit $2
}

has_git() {
  git -C "$1" rev-parse --git-dir >/dev/null 2>&1
  return $?
}

has_ahead() {
  [[ -n $(git -C $1 $g_status | head -1 | grep -oe "\[.*]$") ]]
}

short_path(){
  file="$(simple "${1}")"
  max="${2}"

  if (($#file <= $max)); then
    echo "${file}"
    return
  fi

  base="${file:t}"
  dir=''
  for s ($(echo ${file:h:gs/\// /})) dir+="${s[1]}/"
  echo "${dir}${base}"
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

add_rc(){
  #Check duplicate path and add it to rc_file
  if grep -q "^$1" "${rc_file}"; then
    simple "$1 already exists"
  else
    echo $1 >> "${rc_file}"
  fi
}

add_rc_git(){
  for str in ${@}; do
    local git_path="${str:a}"

    #check valid of path
    if ! has_git "${git_path}"; then
      error "$(simple $git_path) is not git repository" 12
    fi

    add_rc "${git_path}"
  done
}

git_status_and_cmd(){
  local git_path="${1}"
  shift
  simple_color "${git_path}"
  git -C "${git_path}" $g_status
  git -C "${git_path}" $@
}

action_add() {
  [[ $# == 0 ]] && error "Please git repository path or cmd" 10
  if [[ $* =~ ^% ]]; then
    add_rc "${*}"
  else
    add_rc_git ${@}
  fi
}

action_edit(){
  "${EDITOR}" "${rc_file}"
}

action_each(){
  cat "${rc_file}" | grep -v '^[%#]' | while read git_path; do
    simple_color "${git_path}"
    local str="$(git -C "${git_path}" -c color.status=always status --short)"
    # [[ -z $str ]] && continue
    echo -e "${str}"
    git -C "${git_path}" $@
    echo
  done
}

action_shell(){
  cat "${rc_file}" | grep -v '^[%#]' | peco  | while read git_path; do
    echo "Open ${SHELL} in ${git_path}"
    cd "${git_path}"
    "${SHELL}" -i
  done
}

action_not_subcommand() {
  error "wrong $mode is not subcommand" 60
}
