#!/bin/sh

# Manually stow SSH configs
mkdir -p $HOME/.ssh
cp $PWD/linux/ssh/.ssh/config $HOME/.ssh/config

# Manually stow GNUPG configs
mkdir -p $HOME/.gnupg
cp $PWD/linux/gpg/.gnupg/gpg.conf $HOME/.gnupg/gpg.conf
cp $PWD/linux/gpg/.gnupg/gpg-agent.conf $HOME/.gnupg/gpg-agent.conf
