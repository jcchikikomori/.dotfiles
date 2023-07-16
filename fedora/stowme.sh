#!/bin/sh

cd $HOME || return
# Workaround for Fedora
export LD_PRELOAD="/usr/lib64/libgcrypt.so.20"
dotstow stow bash antigen tmux tmuxp vim vscode systems -e=linux -f
dotstow stow zsh git ssh -e=fedora -f
dotstow stow dxvk -e=general -f
