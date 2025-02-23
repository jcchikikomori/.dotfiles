#!/bin/sh

# Manually stow SSH configs
mkdir -p $HOME/.ssh
cp $PWD/linux/ssh/.ssh/config $HOME/.ssh/config

# Manually stow GNUPG configs
# https://gist.github.com/oseme-techguy/bae2e309c084d93b75a9b25f49718f85
mkdir -p $HOME/.gnupg
chown -R $(whoami) $HOME/.gnupg/
chmod 600 $HOME/.gnupg/*
chmod 700 $HOME/.gnupg
cp $PWD/linux/gpg/.gnupg/gpg.conf $HOME/.gnupg/gpg.conf
cp $PWD/linux/gpg/.gnupg/gpg-agent.conf $HOME/.gnupg/gpg-agent.conf

# Kill and restart gpg-agent
gpgconf --kill gpg-agent
echo RELOADAGENT | gpg-connect-agent

# Set TTY environment variable
export GPG_TTY=$(tty)
