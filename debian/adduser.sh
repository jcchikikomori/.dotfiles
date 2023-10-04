#!/bin/sh

# Create non root user
sudo useradd johnc -m
# Using zsh shell
sudo chsh -s /usr/bin/zsh johnc
# Add johnc to sudo group
sudo usermod -aG sudo johnc
# Setting password
if [ -z "$SKIP_SETTING_USER" ]; then
  sudo passwd johnc
else
  echo 'Skipped setting password';
fi
