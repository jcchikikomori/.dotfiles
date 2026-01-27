#!/bin/sh
sh $HOME/.dotfiles/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-cleanup
sh $HOME/.dotfiles/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-ssh
cd $HOME || return
# Workaround for Fedora
export LD_PRELOAD="/usr/lib64/libgcrypt.so.20"
# Generic
dotstow stow bash zsh git antigen tmux tmuxp vim vscode dxvk systems python flatpak alacritty wireplumber flags lindbergh supermodel starship
export LD_PRELOAD=
exit 0
