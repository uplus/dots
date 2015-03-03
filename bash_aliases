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
	;;
esac

alias l='ls -F'
alias la='ls -A'
alias ll='ls -l'
alias lla='ls -lA'

function pushdls(){
	\pushd "$@"
	[ $? == 0 ] && ls
}

function popdls(){
	\popd "$@"
	[ $? == 0 ] && ls
}

function cdls (){ 
	\cd "$@" 
	[ $? == 0 ] && ls
}

function cdlsa (){
	\cd "$@"
	[ $? == 0 ] && ls -A
}

function cdc(){
	cd $HOME/$1
}

function mkdircd(){
	\mkdir "$@"
	[ $? == 0 ] && cd ${!#}
}

function cdh(){
	if [ $# -eq 0 ]; then
		cdls $HOME
	else
		cdls $HOME/$1
	fi
}

function cdr(){
	if [ $# -eq 0 ]; then
		cdls /
	else
		cdls /$1
	fi
}

alias pushd="pushdls"
alias popd="popdls"
alias cd="cdls"
alias cda="cdlsa"
alias ccd="cdls .."
alias cdd="cdls -"

# find aliases
alias findr="find / -name"
alias findh="find ~/ -name"
alias findc="find . -name"

alias vi='vim'
alias vibash="vim ~/.bashrc"
alias vialias="vim ~/.bash_aliases"
alias vim.simp='\vim -u NONE -N'

# Unique aliases
alias envlang="env | egrep --color=never 'LANG|LC'"
alias echo?='echo $?'
alias sln='ln -s'
alias apt-search='\apt-cache search --names-only'
alias apt-upgrade='apt update;echo "##Upgrade start";apt upgrade'

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



# New aliases
alias dotgit='git -C ~/.dotfiles'
alias vimgit='git -C ~/.vim'
alias vi.sjis='vi -c ":e ++enc=cp932"'
alias gv='gvim'
alias cdpu='pushd'
alias cdpo='popd'
alias twme='tw `tw -user:default`'
alias dirsize='du -csh'
