#!/usr/bin/env bash
set -u
# TODO change to absolute
current="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")" && pwd)"


make_dirs_other(){ #{{{
  mkdir -vp $HOME/src
  mkdir -vpm 700 $HOME/codes
} #}}}

make_dirs_mini(){ #{{{
  mkdir -vp $HOME/bin
  mkdir -vpm 700 $HOME/tmp
  mkdir -vpm 700 $HOME/works
  mkdir -vpm 700 $HOME/.ssh
  mkdir -vpm 700 $HOME/.config
  mkdir -vpm 700 $HOME/.cache
} #}}}

link_files() { #{{{
  dir=$current/homedots
  for name in $(ls $dir); do
    ln -svi $dir/$name $HOME/.$name
  done

  lesskey

  mkdir -p $HOME/.peco/
  ln -svi $current/peco.json $HOME/.peco/config.json

  mkdir -p $HOME/.percol.d/
  ln -svi $current/percol.rc.py $HOME/.percol.d/rc.py

  mkdir -p $HOME/.config/lilyterm/
  ln -svi $current/lilyterm-default.conf $HOME/.config/lilyterm/default.conf
} #}}}

link_utils_partial(){ #{{{
  binln $current/utils/chgit.zsh
  binln $current/utils/chrepo.zsh
  binln $current/utils/atoh.rb
  binln $current/utils/htoa.rb
  binln $current/utils/bcho.rb
  binln $current/utils/chpat.rb
} #}}}

setup_zsh(){ #{{{
  ln -svi "$current/zsh/zshenv" "$HOME/.zshenv"
  ln -svi "$current/zsh/zshrc" "$HOME/.zshrc"
  mkdir -p $HOME/.zsh
  zshlocal="${current}/zsh/zshrc.local"
  [[ ! -e $zshlocal ]] && touch "${zshlocal}"

  # zgen
  git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
  zsh -ic ''

  if [[ ! ${SHELL:-} =~ '/zsh' ]]; then
    echo 'Set zsh as default shell'
    chsh -s "$(grep -m 1 zsh /etc/shells)"
  fi
} #}}}

setup_vim(){ #{{{
  git clone https://github.com/uplus/vimrc $HOME/.vim
  install_dein
  mkdir -p $HOME/.vim/tmp

  #nvim
  mkdri -p ~/.config
  ln -svi $HOME/.vim $HOME/.config/nvim
} #}}}

pkg_u(){ # {{{
  _pkg_u() {
    add-apt-repository -y ppa:webupd8team/java
    add-apt-repository -y ppa:git-core/ppa
    apt-get update
    apt-get -y upgrade

    apt-get -y sudo install zsh tmux ssh wget curl git git-sh tig \
      clang clang-doc libclang-dev ruby ruby-dev perl libperl-dev \
      php5 php5-dev python-dev python3-pip lua5.2 luajit tcl-dev libncurses5-dev libncursesw5-dev \
      libmysqld-dev libcurl4-openssl-dev build-essential devscripts \
      vim-gtk exuberant-ctags silversearcher-ag \
      libxt-dev autoconf automake autotools-dev debhelper dh-make fakeroot lintian pkg-config patch \
      patchutils pbuilder x11-xfs-utils terminology iotop htop \
      apt-file gufw gnome-session gwenview xclip rlwrap

  }

  sudo _pkg_u
} #}}}

pkg_u_utility(){ #{{{
  _pkg_u_utility() {
    add-apt-repository -y ppa:neovim-ppa/unstable
    add-apt-repository -y ppa:ubuntu-desktop/ubuntu-make
    add-apt-repository -y ppa:numix/ppa
    add-apt-repository -y ppa:webupd8team/y-ppa-manager
    apt-add-repository -y ppa:screenlets/ppa
    apt-get update

    apt-get -y install gpart gparted \
      qemu-kvm uvtool virtualbox \
      vlc libdvdread4 \
      paprefs pavucontrol \
      ubuntu-make y-ppa-manager ppa-purge \
      mcomix unar gimp  nautilus-image-converter \
      unity-tweak-tool dconf-editor \
      compizconfig-settings-manager compiz-plugins-extra \
      classicmenu-indicator indicator-multiload \
      pavucontrol nodejs sqlite sqlitebrowser zenmap easystroke \
      fontforge python-fontforge open-jtalk espeak \
      ubuntu-restricted-extras \
      asunder soundkonverter lame flac wavpack \
      screenlets screenlets-pack-all

      #interactive
      apt-get install -y wireshark mysql-server oracle-java8-installer oracle-java9-installer
  }

  sudo _pkg_u_utility
} #}}}

pkg_go(){ #{{{
  go get -v -u github.com/motemen/gore
  go get -v -u github.com/peco/peco
  go get -v -u github.com/peco/migemogrep
  go get -v -u github.com/nfs/gocode
  go get -v -u github.com/k0kubun/pp
  go get -v -u github.com/jstemmer/gotags
  go get -v -u golang.org/x/tools/cmd/gorename
  go get -v -u golang.org/x/tools/cmd/goimports
  go get -v -u golang.org/x/tools/cmd/gotype
} #}}}

pkg_python(){ #{{{
  pip install vim-vint --upgrade --user
} #}}}

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
install_dein(){
  git clone --depth 1 https://github.com/Shougo/dein.vim ~/.cache/dein/repos/github.com/Shougo/dein.vim
}

install_peda(){
  git clone --depth 1 https://github.com/scwuaptx/peda.git ~/src/peda
  dotln ~/src/peda
}

install_pwnlib(){
  mkdir ~/.rubylib
  git clone --depth 1 https://github.com/owlinux1000/pwnlib ~/src/pwnlib
  sln ~/src/pwnlib/pwnlib.rb ~/.rubylib/
}

install_fsalib(){
  mkdir ~/.rubylib
  git clone --depth 1 https://github.com/owlinux1000/fsalib ~/src/fsalib
  sln ~/src/fsalib/fsalib.rb ~/.rubylib/
}

install_pwntools(){
  git clone --depth 1 https://github.com/peter50216/pwntools-ruby ~/src/pwntools
  cd ~/src/pwntools
  rake install
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
    go get github.com/peco/peco/cmd/peco
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

install_ruby_with_rbenv() {
  local v19 v20 HEAD
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  # v19=`rbenv install --list | grep -E "\s1\.9\.." | tail -1`
  # v20=`rbenv install --list | grep -E "\s2\.0\.." | tail -1`
  HEAD=$(rbenv install --list | grep -e '^\s\+[0-9]\..\..' | grep -Ev "\-(dev|preview|rc)$" | tail -1)

  # rbenv install $v19
  # rbenv install $v20
  rbenv install $HEAD
  rbenv global $HEAD
  rbenv rehash
  gem update --system
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
  ln -svi ${abs_src} ${abs_dest}
}

dotln () {
	local name
	mkdir -p $HOME/bin
	for name in $@
	do
		ln -svi "${name:a}" "$HOME/.${name:t:r}"
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
