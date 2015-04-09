#!/bin/zsh
local current

which git > /dev/null 
if [ $? -ne 0 ]; then
  echo "please run again after install the git" >&2 
  exit 1
fi

which wget > /dev/null 
if [ $? -ne 0 ]; then
  echo "please run again after install the wget" >&2 
  exit 1
fi
[ ! -d $HOME/bin ] && mkdir $HOME/bin

current=$(cd `dirname $0` && pwd)
ln -svi $current/gitconfig $HOME/.gitconfig

#NeoBundle
mkdir -p ~/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
#vim -c "NeoBundleInstall"


#rbenv
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

# psysh
wget psysh.org/psysh -O $HOME/bin/psysh

#その他にもvimビルドしたりいろいろインストールしたりする予定
