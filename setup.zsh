#!/bin/zsh

which git > /dev/null 
if [ $? -ne 0 ]; then
  echo "please run again after install the git" >&2 
  return 1
fi
ln -s $PWD/gitconfig $HOME/.gitconfig

return 0
exit

#NeoBundle
mkdir -p ~/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
#vim -c "NeoBundleInstall"


#rbenv
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

#実行元にも影響
exec $SHELL -l

#その他にもvimビルドしたりいろいろインストールしたりする予定
