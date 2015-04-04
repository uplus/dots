#/usr/bin/env sh

for name in `\ls`; do
	if [ -f $name ] && [ $name != `basename $0` ] && [ $name != "README.md" ]; then
		ln -svi "$PWD/$name" "$HOME/.$name"
	  # echo "$PWD/$name" "$HOME/.$name"
	fi
done
