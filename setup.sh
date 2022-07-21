#!/usr/bin/env bash
# vim: fdm=marker
set -eu -o pipefail

# TODO: 絶対パスに変える?
current="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")" && pwd)"

## Utils {{{

in_path(){
  which $@ >/dev/null 2>&1
}

binln(){
  local name rpath bname
  [[ ! -d $HOME/bin ]] && mkdir $HOME/bin

  for name in $@; do
    rpath="$(readlink -f "${name}")"
    bname="$(basename "${name}")"
    ln -svi "${rpath}" "${HOME}/bin/${bname%.*}"
  done
}

sln(){
  abs_src="$(readlink -f "${1:?src}")"
  abs_dest="$(readlink -f "${2:?dest}")"
  ln -svin ${abs_src} ${abs_dest}
}

dotln(){
  local name
  mkdir -p $HOME/bin

  for name in $@; do
    ln -svin "${name:a}" "$HOME/.${name:t:r}"
  done
}

get_linux_type(){
  grep -Po '(?<=^ID\=).*|(?<=^ID_LIKE\=).*' /etc/os-release | tr -d '\n'
}

get_os_type(){
  case "${OSTYPE:-}" in
    linux*)  get_linux_type ;;
    darwin*) echo 'macos' ;;
  esac
}

# }}}

mini(){
  setup_dirs
  setup_config_files
  setup_zsh
  setup_vim
  install_peco
}

setup_dirs(){
  mkdir -vpm 700 $HOME/bin
  mkdir -vpm 700 $HOME/.ssh
  mkdir -vpm 700 $HOME/.config
  mkdir -vpm 700 $HOME/.cache

  mkdir -vpm 700 $HOME/tmp
  mkdir -vpm 700 $HOME/works
  mkdir -vpm 700 $HOME/src
  mkdir -vpm 700 $HOME/codes
}

setup_config_files(){
  dir="${current}/rc/dots"
  for name in $(ls "${dir}"); do
    ln -svi "${dir}/${name}" "${HOME}/.$name"
  done

  dir="${current}/rc/config"
  for name in $(ls "${dir}"); do
    ln -svi "${dir}/${name}" "${HOME}/.config/"
  done

  # lesskey
}

setup_zsh(){
  # link configs
  ln -svi "$current/zsh/zshenv" "$HOME/.zshenv"
  ln -svi "$current/zsh/zshrc" "$HOME/.zshrc"

  mkdir -p $HOME/.zsh

  # create zshrc.local
  touch "${current}/zsh/zshrc.local"

    # zgen
  git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
  zsh -ic 'exit'

  if [[ ! ${SHELL:-} =~ '/zsh' ]]; then
    echo 'Set zsh as default shell'
    chsh -s "$(grep -m 1 zsh /etc/shells)"
  fi
}

setup_vim(){
  git clone https://github.com/uplus/vimrc $HOME/.vim

  # neovim
  mkdir -p ~/.config
  ln -svi $HOME/.vim $HOME/.config/nvim

  mkdir -p $HOME/.vim/tmp
  install_dein
}

clone_myrepos_tmp(){
  local ssh my_repo
  echo -n " have you ssh-key of git?(y/N)"
  read -n 1 ssh
  echo
  if [[ $ssh =~ [yY] ]]; then
    my_repo='git@github.com:uplus'
  else
    my_repo='https://github.com/uplus'
  fi

  git clone $my_repo/vimrc.git $HOME/.vim/
  install_dein

  git clone $my_repo/rbrn.git $HOME/codes/rbrn
}

# pkg_ {{{

pkg_go(){
  pkgs=(
    github.com/peco/peco/cmd/peco
    github.com/peco/migemogrep
    github.com/yudai/gotty
    github.com/mikefarah/yq/v4 # jq for YAML
    github.com/simeji/jid/cmd/jid # json incremental digger
    # github.com/motemen/gore # REPL
    github.com/k0kubun/pp
    # github.com/jstemmer/gotags
    github.com/golang/lint/golang
    golang.org/x/tools/cmd/gorename
    golang.org/x/tools/cmd/goimports@latest
    golang.org/x/tools/cmd/gotype
    github.com/itchyny/bed/cmd/bed # binary editor
    github.com/ichinaski/pxl # display images in the terminal
    github.com/monochromegane/the_platinum_searcher/cmd/pt
  )

  for name in ${pkgs[@]}; do
    go install -v "${name}"
  done
}

pkg_pip(){
  pkgs=(vim-vint ipython yamllint s-tui pynvim percol Send2Trash qmk pyls flake8 autopep8)
  pip3 install --upgrade --user ${pkgs[@]}
}

pkg_cargo(){
  pkgs=(
    tealdeer
    tree-sitter-cli
    cargo-update
    cargo-tree
    cargo-asm # クレート::関数でディスアセンブル
    cargo-script
    # cargo-modules
    fd-find
    typos-cli
  )

  for name in ${pkgs[@]}; do
    cargo install "${name}"
  done

  tldr --update
}

pkg_npm(){
  pkgs=(
    pyright
    typescript
    typescript-language-server
  )

  for name in ${pkgs[@]}; do
    npm install -g "${name}"
  done
}

pkg_gem(){
  pkgs=(
    rdoc
    yard
    neovim
    debug
    irb
    gemdiff

    gist
    travis
    solargraph
    dip

    rubocop
    rubocop-performance
    rubocop-rspec

    # console, output
    rb-readline
    color_echo
    awesome_print
    # CLI utils like grep, sed, aws, etc..
    pru

    # Open a library file. gem {edit | open | browse | clone}
    # https://github.com/tpope/gem-browse
    gem-browse
    # gitリポジトリからインストール
    specific_install
    # delete published gem
    # gemcutter

    # TUI filesystem explorer
    rfd
    # Simple SQL Linter
    sqlint

    google-api-client
    octokit

    parser
    nokogiri
    mechanize
  )

  gem install ${pkgs[@]}
}

pkg_brew(){
  pkgs=(
    # 標準のgitはなんか重い
    git
    exa ripgrep peco
    gcc go rust
    shellcheck
    coreutils findutils iproute2mac luajit grep pgrep pkill watch
    fswatch svn tig tree wget curl tmux pwgen jq nkf deno libtool pkg-config gettext
    automake cmake ctop direnv graphviz llvm ninja openssl@3 proctools qmk/qmk/qmk sshuttle yarn git-secrets 
  )

  brew install ${pkgs[@]}

  brew install --cask alacritty alt-tab gimp homebrew/cask-fonts/font-source-code-pro homebrew/cask-fonts/font-source-code-pro-for-powerline
  # brew install neovim --HEAD
  # brew install --cask vagrant virtualbox
}


# }}}

# install_ {{{
install_echo_sd(){
  wget https://raw.githubusercontent.com/fumiyas/home-commands/master/echo-sd -O ~/bin/echo-sd
  chmod +x !$
}

install_ctop(){
  wget https://github.com/bcicen/ctop/releases/download/v0.7.2/ctop-0.7.2-linux-amd64 -O ~/bin/ctop
  chmod +x !$
}

install_dein(){
  git clone --depth 1 https://github.com/Shougo/dein.vim ~/.cache/dein/repos/github.com/Shougo/dein.vim
}

install_peco(){
  if in_path go; then
    go get -u github.com/peco/peco/cmd/peco
  else
    install_peco_wget
  fi
}

install_peco_wget(){
  req_url='https://api.github.com/repos/peco/peco/releases'
  target='peco_linux_amd64'
  get_url="$(curl -sS "${req_url}" | grep 'browser_download_url' | grep "${target}" | head -1 | awk '$0=$2' | tr -d '"')"
  wget "${get_url}" -O - | tar zxf -
  mv "${target}/peco" "$HOME/bin" && rm -r "${target}"
}

install_ripgrep(){
  case "$(get_os_type)" in
    'arch') sudo pacman -S ripgrep ;;
    'macos') brew install ripgrep ;;
  esac
}

install_qmk(){
  pacman -S --no-confirm avr-gcc avr-libc dfu-util
  yaourt -S --no-confirm dfu-programmer teensy-loader-cli
}
#}}}

# misc {{{

set_cap_nmap(){
  sudo setcap cap_net_raw,cap_net_admin,cap_net_bind_service,cap_net_broadcast+eip /usr/bin/nmap
}

vul_env(){
  docker pull citizenstig/dvwa
}

ime_vars(){
  cat <<- END | sudo tee -a /etc/profile

export XIM_PROGRAM="fcitx"
export XIM="fcitx"
export XIM_ARGS="-d"
export GTK_IM_MODULE="fcitx"
export QT_IM_MODULE="fcitx"
export ECORE_IMF_MODULE="xim"
export XMODIFIERS="@im=fcitx"
END
}

set_dark_theme(){
  local gtk_config="$HOME/.config/gtk-3.0"
  [[ -d $gtk_config ]] && mkdir -p "$gtk_config"
  ln -svi $current/gtk3.css $gtk_config/gtk3.css
  echo '@import url("gtk3.css");'>> "$gtk_config/gtk.css"
}

disable_settings_daemon_keyboard(){
  dconf write /org/gnome/settings-daemon/plugins/keyboard/active false
}

change_keymap(){
  sudo ln -s $current/u10.xkb /usr/share/X11/xkb/symbols/u10
  sudo rm /var/lib/xkb/*

  echo "
! option = symbols
  u10:happy  = +u10(happy)
  u10:tenkey = +u10(tenkey)" | sudo tee -a /usr/share/X11/xkb/rules/evdev

  dconf write /org/gnome/desktop/input-sources/xkb-options "['ctrl:nocaps', 'u10:happy', 'u10:tenkey']"
  # $ setxkbmap -option ctrl:nocaps -option u10:happy -option u10:tenkey
}

#}}}

# TODO: つくる
get_pkg_manager(){
  case "$(get_os_type)" in
    *arch*)
      alias a.i='sudo pacman -S --noconfirm'
      alias a.u='sudo pacman -Syyu --noconfirm'
      alias a.ud='sudo pacman -Syy'
      ;;
    *debian*)
      alias a.i='sudo apt-get install -y'
      alias a.u='sudo apt-get update && sudo apt-get upgrade -y'
      alias a.ud='sudo apt-get update'
      ;;
    *fedora*)
      if in_path dnf; then
        alias a.i='sudo dnf install -y'
        alias a.u='sudo dnf upgrade -y'
        alias a.ud='sudo dnf upgrade -y'
      else
        alias a.i='sudo yum install -y'
        alias a.u='sudo yum update -y'
        alias a.ud='sudo yum update -y'
      fi
      ;;
    *)
      echo 'cannot detect os' >&2
  esac
}

help(){
  grep -o "^[^ ]*()" "${current}/setup.sh" | sed "s/()//g"
}

if [ $# -eq 0 ]; then
  help
else
  $1
fi
