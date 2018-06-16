#!/usr/bin/env bash

# Always better to have everything up-to-date
sudo pacman -Syu git neovim
export EDITOR=nvim

# Git bare repo command
dot="git --git-dir=$HOME/.dot/ --work-tree=$HOME"

cd $HOME

git clone --bare https://gitlab.com/reisub0/dot $HOME/.dot

echo 'This will overwrite most of your home directory contents. (After a backup in Backup directory)'
echo 'Preferable to do this on a brand new system'
read -p "Are you sure to continue? " -n 1 -r

echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Making Backup..."
	mkdir -p Backup
	# Backup all files/directories starting with a dot
	find -maxdepth 1  -regex '\.\/\..*'  -exec cp -vr \{\} ./Backup/ \;
	echo "Checking out dot..."
	# Checkout the cloned repo
	$dot checkout -f HEAD

	# Since we have our private SSH keys now, we can skip the cumbersome Username/Password step
	sed 's|https://github.com/|git@gitlab.com-reisub0:|' ~/dot/config > ~/dot/config.bak && mv ~/dot/config.bak ~/dot/config
	echo -e '[status]\n\tshowUntrackedFiles = no' >> ~/dot/config

	# Reload new checked out bashrc to get our functions (archInit)
	. ~/.bashrc

	# Install all the packages
	archInit
	pakInstall

	pakku -S --noconfirm powerpill
fi

read -p "Update neovim plugins? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	nvim +PlugInstall
fi

echo "All done"
