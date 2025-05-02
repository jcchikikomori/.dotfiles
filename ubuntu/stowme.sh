#!/bin/sh
sh $HOME/.dotfiles/linux/zsh/bin/dotfiles-cleanup
sh $HOME/.dotfiles/linux/zsh/bin/dotfiles-ssh
cd $HOME || return
dotstow stow zsh git antigen tmux tmuxp vim vscode dxvk systems
cd $HOME/.dotfiles
git reset --hard HEAD
exit 0
