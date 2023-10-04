#!/bin/sh

# Create non root user
sudo useradd admin -m
# Using zsh shell
sudo usermod -s /bin/zsh admin
# Add admin to wheel group
sudo usermod -aG wheel admin
# Setting password
if [ -z "$SKIP_SETTING_USER" ]; then
  sudo passwd admin
else
  echo 'Skipped setting password';
fi
