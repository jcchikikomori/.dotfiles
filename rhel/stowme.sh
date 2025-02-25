#!/bin/sh

echo 'Cleaning up...'
cd ..
./cleanup.sh

echo 'Executing general workarounds...'
# cp -f $PWD/rhel/ssh/.ssh/config $HOME/.ssh/config
./manual.sh

cd $HOME || return

# Workaround for Fedora
export LD_PRELOAD="/usr/lib64/libgcrypt.so.20"

# Generic
dotstow stow systems zsh git antigen tmux tmuxp vim vscode dxvk

# Fedora-related
dotstow stow test-fedora

echo 'Linking profile...'
ln -sf ~/.zprofile ~/.profile

export LD_PRELOAD=
exit 0
