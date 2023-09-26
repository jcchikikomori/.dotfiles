#!/bin/sh
# THIS SCRIPT IS FOR ROOT USER ONLY. DO NOT EXECUTE THE SCRIPT AS NON-ROOT USER!

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
apt-get install -y sudo htop iftop mtr dkms lz4 git zsh stow build-essential sqlite3 ccache tmux

# Create non root user
useradd johnc -m
# Using zsh shell
chsh -s /usr/bin/zsh johnc
# Add johnc to sudo group
usermod -aG sudo johnc
# Setting password
if [ -z "$SKIP_SETTING_USER" ]; then
  passwd johnc
else
  echo 'Skipped setting password';
fi
