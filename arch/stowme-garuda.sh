#!/bin/sh

echo 'Cleaning up...'
cd ..
./cleanup.sh

cd $HOME || return
dotstow stow bash antigen tmux tmuxp vim vscode systems -f
dotstow stow zsh-garuda git-garuda ssh-garuda -f
