#!/bin/sh

echo 'Cleaning up...'
cd ..
./cleanup.sh

echo 'Executing general workarounds...'
# cp -f $PWD/rhel/ssh/.ssh/config $HOME/.ssh/config
./manual.sh

cd $HOME || return
dotstow stow systems zsh git antigen tmux tmuxp vim vscode dxvk

exit 0
