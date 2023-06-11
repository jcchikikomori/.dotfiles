#!/bin/sh

cd $HOME || return
# Workaround for Fedora
export LD_PRELOAD="/usr/lib64/libgcrypt.so.20"
dotstow stow zsh antigen tmux tmuxp vim git ssh vscode systems -e=fedora -f
