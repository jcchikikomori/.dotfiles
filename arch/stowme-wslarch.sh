#!/bin/sh

echo 'Cleaning up...'
cd ..
./cleanup.sh

cd $HOME || return
dotstow stow bash antigen tmux tmuxp vim vscode systems -e=linux
dotstow stow zsh-wslarch git-wslarch ssh-wslarch
