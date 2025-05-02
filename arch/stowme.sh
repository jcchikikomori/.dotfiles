#!/bin/sh

# Arch-related workarounds
# locale-gen en_US.UTF-8
# localectl set-locale LANG=en_US.UTF-8

sh $HOME/.dotfiles/linux/zsh/bin/dotfiles-cleanup
sh $HOME/.dotfiles/linux/zsh/bin/dotfiles-ssh
cd $HOME || return
dotstow stow zsh git antigen tmux tmuxp vim vscode dxvk systems
exit 0
