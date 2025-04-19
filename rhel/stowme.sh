#!/bin/sh

# echo 'Cleaning up...'
# cd ..
# dotfiles-cleanup

# echo 'Executing general workarounds...'
# cp -f $PWD/rhel/ssh/.ssh/config $HOME/.ssh/config
# dotfiles-ssh

cd $HOME || return

# Workaround for Fedora
export LD_PRELOAD="/usr/lib64/libgcrypt.so.20"

# Generic
dotstow stow systems zsh git antigen tmux tmuxp vim vscode dxvk

export LD_PRELOAD=
exit 0
