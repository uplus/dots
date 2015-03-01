for name in `\ls`; do
	if [ -f $name ] && [ $name != `basename $0` ] && [ $name != "README.md" ]; then
		ln -svi $name "$HOME/.$name"
	fi
done
