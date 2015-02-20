# to color output
alias ls='ls  --color'
alias grep='egrep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'

# some more ls aliases
alias l='ls -F'
alias la='ls -A'
alias ll='ls -l'
alias lla='ls -lA'

# find aliases
alias findr="find / -name"
alias findh="find ~/ -name"
alias findc="find . -name"

alias vi='vim'
alias vibash="vim + ~/.bashrc"
alias vialias="vim + ~/.bash_aliases"
alias vim.simp='\vim -u NONE -N'

# Unique aliases
alias envlang="env | egrep --color=never 'LANG|LC'"
alias echo?='echo $?'
alias sln='ln -s'
alias apt-search='apt-cache pkgnames | egrep'
alias apt-upgrade='apt update;apt upgrade'

# Clang aliases
export CLANG_WALL_OPT='-Wall -Wextra -Wno-unused-parameter -Wno-unused-variable'
alias clang="clang $CLANG_WALL_OPT -lm -std=c11"
alias clang++="clang++ $CLANG_WALL_OPT -std=c++1z"

export GCC_OPT="-std=c11 -lm -O0 -fno-stack-protector $CLANG_WALL_OPT"
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
alias rm='rm -iv'

# not require sudo
alias shutdown='sudo shutdown'
alias poweroff='sudo poweroff'
alias reboot='sudo reboot'
alias apt-get='sudo apt-get'
alias apt='sudo apt'
alias mount='sudo mount'
alias dotgit='git -C ~/.dotfiles'

# New aliases
alias visjis='vi -c ":e ++enc=cp932"'
