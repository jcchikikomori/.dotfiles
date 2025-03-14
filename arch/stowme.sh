#!/bin/sh

# Arch-related workarounds
# locale-gen en_US.UTF-8
# localectl set-locale LANG=en_US.UTF-8

echo 'Cleaning up...'
cd ..
./cleanup.sh

echo 'Executing general workarounds...'
# cp -f $PWD/rhel/ssh/.ssh/config $HOME/.ssh/config
./manual.sh

cd $HOME || return
dotstow stow systems zsh git antigen tmux tmuxp vim vscode dxvk

echo 'Linking profile...'
ln -sf ~/.zprofile ~/.profile

exit 0
