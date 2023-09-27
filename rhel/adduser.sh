#!/bin/sh

# Create non root user
sudo useradd admin -m
# Using zsh shell
sudo chsh -s /usr/bin/zsh admin
# Add admin to sudo group
sudo usermod -aG sudo admin
# Setting password
if [ -z "$SKIP_SETTING_USER" ]; then
  sudo passwd admin
else
  echo 'Skipped setting password';
fi
