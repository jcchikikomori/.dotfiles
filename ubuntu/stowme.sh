#!/bin/sh
sh $HOME/.dotfiles/linux/zsh/bin/dotfiles-cleanup
sh $HOME/.dotfiles/linux/zsh/bin/dotfiles-ssh
cd $HOME || return
dotstow stow bash zsh git antigen tmux tmuxp vim vscode dxvk systems flatpak alacritty wireplumber
exit 0
