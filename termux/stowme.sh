#!/bin/sh
sh $HOME/.dotfiles/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-cleanup
sh $HOME/.dotfiles/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-ssh
cd $HOME || return
dotstow stow bash zsh git antigen tmux tmuxp vim vscode dxvk systems flatpak alacritty wireplumber flags lindbergh starship
exit 0
