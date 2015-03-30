#!/bin/bash
# to color output
case $OSTYPE in
linux*)
	alias ls='ls  --color'
	alias grep='\egrep --color'
	alias egrep='\egrep --color'
	alias fgrep='\fgrep --color'
	;;
darwin*)
	alias ls='ls  -G'
	alias grep='egrep -G'
	alias egrep='egrep -G'
	alias fgrep='\fgrep --color'
	;;
esac

alias l='ls -F'
alias la='ls -A'
alias ll='ls -l'
alias lla='ls -lA'

function mcdir(){
	mkdir $* && cd ${!#}
}

function ch(){
	if [ $# -eq 0 ]; then
		cd $HOME
	else
		cd $HOME/$1
	fi
}

function cr(){
	if [ $# -eq 0 ]; then
		cd /
	else
		cd /$1
	fi
}

alias ccd="cd .."
alias cdd="cd -"
alias cdpu='pushd'
alias cdpo='popd'

# find aliases
alias findr="find / -name"
alias findh="find ~/ -name"
alias findc="find . -name"

alias vi='vim'
alias vibash="vim ~/.bashrc"
alias vialias="vim ~/.bash_aliases"
alias vim.simp='\vim -u NONE -N'
alias vi.sjis='vi -c ":e ++enc=cp932"'
alias gv='gvim'

# Unique aliases
alias envlang="env | egrep --color=never 'LANG|LC'"
alias echo?='echo $?'
alias sln='ln -s'
alias apt-search='\apt-cache search --names-only'
alias apt-upgrade='apt update && echo "##Upgrade start" && apt upgrade'

# Clang aliases
export C_CPP_WALL_OPT='-Wall -Wextra -Wno-unused-parameter -Wno-unused-variable -Wno-unused-value'
export C_COMP_OPT="$C_CPP_WALL_OPT -lm -std=c11"
export CPP_COMP_OPT="$C_CPP_WALL_OPT -std=c++1z"

alias clang="clang $C_COMP_OPT"
alias clang++="clang++ $CPP_COMP_OPT"

export GCC_OPT="$C_COMP_OPT -O0 -fno-stack-protector" 
alias gcc="\gcc $GCC_OPT" 
alias gccg="\gcc -g $GCC_OPT"
alias gcc32="\gcc -m32 $GCC_OPT"
alias gccg32="\gcc -g -m32 $GCC_OPT"
alias gdb='gdb -q'
alias gdba='gdb -q a.out'
alias objdump='objdump -M intel'

alias irb='irb --simple-prompt'
alias pry='pry --simple-prompt'

# to safely used.
alias mv='mv -iv'
alias cp='cp -iv'
alias rm='rm -v'

# not require sudo
alias shutdown='sudo shutdown'
alias poweroff='sudo poweroff'
alias reboot='sudo reboot'
alias apt-get='sudo apt-get'
alias apt='sudo apt'
alias mount='sudo mount'
alias visudo='sudo visudo'

function hv(){
	[ -z $1 ] && return 1
	$1 --help 2>&1 | view -
}

# New aliases
alias dotgit='git -C ~/.dotfiles'
alias vimgit='git -C ~/.vim'
alias twme='tw `tw -user:default`'
alias dirsize='du -csh'
alias resh='exec $SHELL -l'
alias be='bundle exec'
alias gs='git status --short'
alias gd='git diff'
alias gl='git log --oneline'
