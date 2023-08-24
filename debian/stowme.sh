#!/bin/sh

echo 'Cleaning up...'
cd ..
./cleanup.sh

cd $HOME || return
dotstow stow bash antigen ssh tmux tmuxp vim vscode systems dxvk
dotstow stow zsh git
