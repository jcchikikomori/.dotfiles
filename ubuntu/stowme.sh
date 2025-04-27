#!/bin/sh
sh $HOME/bin/dotfiles-cleanup
sh $HOME/bin/dotfiles-ssh
cd $HOME || return
dotstow stow zsh git antigen tmux tmuxp vim vscode dxvk systems
exit 0
