#!/bin/sh

echo 'Cleaning up...'
cd ..
./cleanup.sh

echo 'Executing general workarounds...'
# cp -f $PWD/rhel/ssh/.ssh/config $HOME/.ssh/config
./manual.sh

cd $HOME || return
dotstow stow bash git antigen tmux tmuxp vim vscode systems dxvk
dotstow stow zsh

exit 0
