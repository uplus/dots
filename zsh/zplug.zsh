
zplug 'zplug/zplug'
# zplug 'tarruda/zsh-autosuggestions'
# zplug 'hchbaw/auto-fu.zsh' && zle-line-init(){ auto-fu-init } # interactive completion
# zplug 'mollifier/anyframe'
# zplug 'zsh-users/zaw' # TODO: error:android

zplug 'm4i/cdd', use:cdd, as:plugin, nice:18
# zplug 'rimraf/k' # TODO: error:android: zmodload -F zsh/stat b:zstat
zplug 'junegunn/fzf', as:command, use:bin/fzf-tmux
# zplug 'junegunn/fzf-bin', as:command, from:gh-r, rename-to:fzf
# zplug 'peco/peco', from:gh-r, as:command, use:'*linux*amd64*'
# zplug 'peco/migemogrep', as:command, from:gh-r, use:'*linux_amd64*'
zplug 'philovivero/distribution', as:command, use:distribution.py, rename-to:distribution
zplug "tcnksm/docker-alias", use:zshrc
zplug "mollifier/zload" # reload zsh completion function.
zplug 'Russell91/sshrc', as:command, use:sshrc
# zplug 'b4b4r07/gomi', from:gh-r, as:command, use:'*linux_amd64*', rename-to:gomi
zplug 'b4b4r07/enhancd', as:plugin, use:enhancd.sh
zplug 'arks22/tmuximum', as:command, use:tmuximum

zplug 'zsh-users/zsh-completions'
zplug "zsh-users/zsh-syntax-highlighting", nice:19
