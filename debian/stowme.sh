#!/bin/sh

echo 'Cleaning up...'
cd ..
dotfiles-cleanup

echo 'Executing general workarounds...'
# cp -f $PWD/rhel/ssh/.ssh/config $HOME/.ssh/config
dotfiles-ssh

cd $HOME || return
dotstow stow systems zsh git antigen tmux tmuxp vim vscode dxvk

exit 0
