#!/bin/sh
sh $HOME/.dotfiles/linux/zsh/bin/dotfiles-cleanup
sh $HOME/.dotfiles/linux/zsh/bin/dotfiles-ssh
cd $HOME || return
# Workaround for Fedora
export LD_PRELOAD="/usr/lib64/libgcrypt.so.20"
# Generic
dotstow stow bash zsh git antigen tmux tmuxp vim vscode dxvk systems wireplumber
export LD_PRELOAD=
exit 0
