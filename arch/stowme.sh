#!/bin/sh

# Arch-related workarounds
# locale-gen en_US.UTF-8
# localectl set-locale LANG=en_US.UTF-8

sh $HOME/bin/dotfiles-cleanup
sh $HOME/bin/dotfiles-ssh
cd $HOME || return
dotstow stow systems zsh git antigen tmux tmuxp vim vscode dxvk

exit 0
