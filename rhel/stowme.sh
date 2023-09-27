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
dotstow stow zsh git antigen tmux tmuxp vim vscode systems dxvk

# Fedora-related
dotstow stow test-fedora

export LD_PRELOAD=
exit 0
