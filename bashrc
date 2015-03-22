# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
# HISTCONTROL=ignoreboth:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
    else
		color_prompt=
    fi
fi

case $OSTYPE in
linux*)
  if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\e[2;36m\]\u@\[\e[00m\]\[\e[01;34m\]\w\[\e[00m\]\[\033[31m\]$(__git_ps1)\[\033[00m\]\$ '
  else
      PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
  fi
  unset color_prompt force_color_prompt
  ;;
darwin*)
  source /etc/bashrc
  ;;
esac

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


######NEW######NEW######NEW######NEW######NEW######NEW######NEW########
# Order is important
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH="./:./bundle_bin:$HOME/bin:$PATH"

# git-completion系
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

if [ -f $HOME/.bash_completion ]; then
	source $HOME/.bash_completion
fi

if [ -n "$WINDOWID" -a -f $HOME/.xmodmap ]; then
	xmodmap ~/.xmodmap
fi

#Ctrl-S need this codes
stty -ixon -ixoff

#cdを省略できる
shopt -s autocd

function ls_after_cd(){
  [[ -n $JUST_BEFORE_PWD ]] && [[ $JUST_BEFORE_PWD != $PWD ]] && ls
  JUST_BEFORE_PWD=$PWD
}

function share_history(){
  history -a
  history -c
  history -r
}

export PROMPT_COMMAND="ls_after_cd; share_history;"

#Need restart the bash to apply
addalias(){
	if [ $# -ge 2 ]; then # $? >= 2
		NAME=$1
		shift
		echo "alias $NAME='$*'" >> ~/.bash_aliases
	else
		echo "syntax error" > /dev/stderr
	fi
}

tmpalias(){
  if [ $# -ge 2 ]; then # #? >= 2
    NAME=$1
    shift
    echo "alias $NAME='$*'" >> ~/.tmp_aliases
  else
    echo "syntax error" > /dev/stderr
  fi
}

gor(){
  while [ ! -f Gemfile ] && [[ $PWD != '/' ]]; do
    cd ..
  done
}

gsh(){
  #opt parse
  OPT=$*

  while :; do
    echo -ne "\033[31m$(__git_ps1)\033[00m "
    read cmd
    if [[ -z $cmd ]]; then
      git $OPT status
    elif [[ "exit" = $cmd ]]; then
      break
    else
      git $OPT $cmd
    fi

  done
}
