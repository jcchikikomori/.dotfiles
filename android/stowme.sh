#!/bin/sh

echo 'Cleaning up...'
cd ..
./cleanup.sh

cd $HOME || return
dotstow stow bash antigen tmux tmuxp vim systems
dotstow stow vnc-android zsh-android
