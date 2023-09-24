#!/bin/sh

echo 'Cleaning up...'
cd ..
./cleanup.sh

cd $HOME || return
# Workaround for Fedora
export LD_PRELOAD="/usr/lib64/libgcrypt.so.20"
dotstow stow bash antigen ssh gpg tmux tmuxp vim vscode systems dxvk
dotstow stow zsh git test-fedora
