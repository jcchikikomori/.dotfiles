#!/bin/sh

# Arch-related workarounds
# locale-gen en_US.UTF-8
# localectl set-locale LANG=en_US.UTF-8

sh $HOME/.dotfiles/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-cleanup
sh $HOME/.dotfiles/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-ssh
cd $HOME || return
dotstow stow bash zsh git antigen tmux tmuxp vim vscode dxvk systems python flatpak alacritty wireplumber flags lindbergh supermodel starship
exit 0
