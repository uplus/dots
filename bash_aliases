alias envlang="env | egrep --color=never 'LANG|LC'"
alias apt-search='apt-cache pkgnames | egrep'
alias echo?='echo $?'

alias ls='ls  --color'
alias grep='egrep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'

# some more ls aliases
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -l'
alias lla='ls -lA'

alias findr="find / -name"
alias findh="find ~/ -name"
alias findc="find . -name"

alias vi='vim'
alias vibash="vim + ~/.bashrc"
alias vialias="vim + ~/.bash_aliases"

alias clang='clang -Wall -W -lm -std=gnu99'
alias clang++='clang++ -Wall -W -std=c++1z'

alias irb='irb --simple-prompt'
alias pry='pry --simple-prompt'

alias objdump='objdump -M intel'
alias gcc='gcc -O0 -std=gnu99 -fno-stack-protector'
alias gccg='gcc -O0 -g -std=gnu99 -fno-stack-protector'
alias gcc32='gcc -O0 -m32 -std=gnu99 -fno-stack-protector'
alias gccg32='gcc -O0 -g -m32 -std=gnu99 -fno-stack-protector'
alias gdba='gdb -q a.out'
alias gdb='gdb -q'

alias sln='ln -s'
alias mv='mv -iv'
alias cp='cp -iv'
alias rm='rm -iv'

alias shutdown='sudo shutdown'
alias poweroff='sudo poweroff'
alias reboot='sudo reboot'
alias apt-get='sudo apt-get'
alias mount='sudo mount'
