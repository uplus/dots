#!/usr/bin/env bash
set -u
# TODO change to absolute
current="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")" && pwd)"


make_dirs_other(){
  mkdir -vp $HOME/src
  mkdir -vpm 700 $HOME/codes
}

make_dirs_mini(){
  mkdir -vp $HOME/bin
  mkdir -vpm 700 $HOME/tmp
  mkdir -vpm 700 $HOME/works
  mkdir -vpm 700 $HOME/.ssh
  mkdir -vpm 700 $HOME/.config
  mkdir -vpm 700 $HOME/.cache
}

link_files() {
  dir=$current/homedots
  for name in $(ls $dir); do
    ln -svi $dir/$name $HOME/.$name
  done

  lesskey
}

link_utils_partial(){
  binln $current/utils/chgit.zsh
  binln $current/utils/chrepo.zsh
  binln $current/utils/atoh.rb
  binln $current/utils/htoa.rb
  binln $current/utils/bcho.rb
  binln $current/utils/chpat.rb
}

setup_zsh(){
  ln -svi "$current/zsh/zshenv" "$HOME/.zshenv"
  ln -svi "$current/zsh/zshrc" "$HOME/.zshrc"
  mkdir -p $HOME/.zsh
  zshlocal="${current}/zsh/zshrc.local"
  [[ ! -e $zshlocal ]] && touch "${zshlocal}"

  if [[ ! ${SHELL:-} =~ '/zsh' ]]; then
    echo 'Set zsh as default shell'
    chsh -s "$(grep -m 1 zsh /etc/shells)"
  fi

  # zgen
  git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
  zsh -ic 'exit'
}

setup_vim(){
  git clone https://github.com/uplus/vimrc $HOME/.vim
  install_dein
  mkdir -p $HOME/.vim/tmp

  #nvim
  mkdir -p ~/.config
  ln -svi $HOME/.vim $HOME/.config/nvim
}

pkg_go(){
  pkgs=(
    github.com/motemen/gore # REPL
    github.com/peco/peco/cmd/peco
    github.com/peco/migemogrep
    github.com/jingweno/ccat # color cat
    github.com/nfs/gocode
    github.com/k0kubun/pp
    github.com/jstemmer/gotags
    github.com/golang/lint/golang
    golang.org/x/tools/cmd/gorename
    golang.org/x/tools/cmd/goimports
    golang.org/x/tools/cmd/gotype
    github.com/itchyny/bed/cmd/bed # binary editor
    github.com/monochromegane/the_platinum_searcher/cmd/pt
    github.com/orisano/rget # parallel download
    github.com/yudai/gotty
    github.com/sacloud/usacloudy
  )

  for name in ${pkgs[@]}; do
    go get -v -u "${name}"
  done
}

pkg_pip(){
  pkgs=(vim-vint ipython yamllint s-tui pynvim percol Send2Trash qmk pyls flake8 autopep8)
  pip3 install --upgrade --user ${pkgs[@]}
}

pkg_cargo(){
  pkgs=(
    tealdeer
    cargo-update
    cargo-tree
    cargo-asm # クレート::関数でディスアセンブル
    cargo-script
    # cargo-modules
    fd-find
  )

  for name in ${pkgs[@]}; do
    cargo install "${name}"
  done

  tldr --os=linux --update
}

pkg_npm(){
  pkgs=(
    write-good
    neovim
    javascript-typescript-stdio
    underscore
  )

  for name in ${pkgs[@]}; do
    npm install -g "${name}"
  done
}

pkg_gem() {
  pkgs=(
    yard
    neovim
    gist
    travis
    rubocop
    solargraph

    # console, output
    rb-readline
    color_echo
    awesome_print

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

    nokogiri
    mechanize
  )

  gem install ${pkgs[@]}
}

pkg_brew() {
  pkgs=(
    coreutils findutils iproute2mac luajit pgrep pkill fswatch
    tig tree wget curl tmux ripgrep circleci pwgen peco jq
  )

  brew install neovim --HEAD
  brew install ${pkgs[@]}
  brew install --cask font-source-code-pro font-source-code-pro-for-powerline
  # brew install --cask vagrant virtualbox
}

clone_myrepos_tmp(){ #{{{
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
} #}}}

# installs {{{
install_echo_sd(){
  wget https://raw.githubusercontent.com/fumiyas/home-commands/master/echo-sd -O ~/bin/echo-sd
  chmod +x !$
}

install_ctop() {
  wget https://github.com/bcicen/ctop/releases/download/v0.7.2/ctop-0.7.2-linux-amd64 -O ~/bin/ctop
  chmod +x !$
}

install_dein(){
  git clone --depth 1 https://github.com/Shougo/dein.vim ~/.cache/dein/repos/github.com/Shougo/dein.vim
}

install_other(){
  # json incremental digger
  go get -v github.com/simeji/jid/cmd/jid

  # display images in the terminal
  go get -v github.com/ichinaski/pxl

  # go completion
  go get -v github.com/nsf/gocode
  gocode set autobuild true
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

install_rbenv() {
  git clone --depth 1 https://github.com/sstephenson/rbenv.git ~/.rbenv
  git clone --depth 1 https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
  git clone --depth 1 https://github.com/sstephenson/rbenv-default-gems.git ~/.rbenv/plugins/rbenv-default-gems
  git clone --depth 1 https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
  git clone --depth 1 https://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update
  ln -svi $current/default-gems $HOME/.rbenv/default-gems
}

install_linuxbrew() {
  git clone https://github.com/Homebrew/linuxbrew.git ~/.linuxbrew
}

install_tig(){
  git clone https://github.com/jonas/tig ~/src/tig/
  pushd ~/src/tig
  make configure
  ./configure --with-ncursesw
  make prefix=/usr/local
  sudo make install prefix=/usr/local
  # sudo make install-doc prefix=/usr/local
  popd $current
}

install_psysh() {
  [ ! -e $HOME/bin/psysh ] && wget psysh.org/psysh -O $HOME/bin/psysh
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

vlc_dvd(){
  sudo apt-get install vlc libdvdread4
  sudo /usr/share/doc/libdvdread4/install-css.sh
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

mini(){
  make_dirs_mini
  link_files
  link_utils_partial
  setup_zsh
  setup_vim
  install_peco
}

# TODO making
myenv(){
  mini
  make_dirs_other
}

# TODO tmp
#TODO: ubuntu centos archに対応させる
#       rubyやclang,phpなどバージョンがめんどくさいリポジトリがある
common_apps() {
  local -a a b
  a="openssh zsh git tig curl wget tmux tree"
  b="gcc clang go ruby python python3 php lua luajit"
}

in_path(){
  which $@ >/dev/null 2>&1
}

binln () {
  local name rpath bname
  [[ ! -d $HOME/bin ]] && mkdir $HOME/bin
  for name in $@
  do
    rpath="$(readlink -f "${name}")"
    bname="$(basename "${name}")"
    ln -svi "${rpath}" "${HOME}/bin/${bname%.*}"
  done
}

sln () {
  abs_src="$(readlink -f "${1:?src}")"
  abs_dest="$(readlink -f "${2:?dest}")"
  ln -svin ${abs_src} ${abs_dest}
}

dotln () {
  local name
  mkdir -p $HOME/bin
  for name in $@
  do
    ln -svin "${name:a}" "$HOME/.${name:t:r}"
  done
}

# TODO making
get_pkg_manager(){
  case "$(grep -Po '(?<=^ID\=).*|(?<=^ID_LIKE\=).*' /etc/os-release)" in
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

# vim: fdm=marker
