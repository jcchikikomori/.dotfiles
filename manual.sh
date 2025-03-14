#!/bin/sh

# Manually stow SSH configs
mkdir -p $HOME/.ssh
if [ -f $HOME/.ssh/config ]; then
  mv $HOME/.ssh/config $HOME/.ssh/config.bak
fi
ln -sf $PWD/linux/ssh/.ssh/config $HOME/.ssh/config

# Manually stow GNUPG configs
# https://gist.github.com/oseme-techguy/bae2e309c084d93b75a9b25f49718f85
mkdir -p $HOME/.gnupg
chown -R $(whoami) $HOME/.gnupg/
chmod 700 $HOME/.gnupg
if [ -f $HOME/.gnupg/gpg.conf ]; then
  mv $HOME/.gnupg/gpg.conf $HOME/.gnupg/gpg.conf.bak
fi
if [ -f $HOME/.gnupg/gpg-agent.conf ]; then
  mv $HOME/.gnupg/gpg-agent.conf $HOME/.gnupg/gpg-agent.conf.bak
fi
ln -sf $PWD/linux/gpg/.gnupg/gpg.conf $HOME/.gnupg/gpg.conf
ln -sf $PWD/linux/gpg/.gnupg/gpg-agent.conf $HOME/.gnupg/gpg-agent.conf

# Check if gpgconf and gpg-connect-agent commands exist
if command -v gpgconf >/dev/null 2>&1 && command -v gpg-connect-agent >/dev/null 2>&1; then
  # Kill and restart gpg-agent
  gpgconf --kill gpg-agent
  echo RELOADAGENT | gpg-connect-agent

  # Set TTY environment variable
  export GPG_TTY=$(tty)
else
  echo "Error: gpgconf and/or gpg-connect-agent commands not found." >&2
  exit 1
fi
