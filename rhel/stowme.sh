#!/bin/sh
sh $HOME/bin/dotfiles-cleanup
sh $HOME/bin/dotfiles-ssh
cd $HOME || return
# Workaround for Fedora
export LD_PRELOAD="/usr/lib64/libgcrypt.so.20"
# Generic
dotstow stow zsh git antigen tmux tmuxp vim vscode dxvk
export LD_PRELOAD=
exit 0
