#!/bin/sh

# Create non root user
sudo useradd johnc -m
# Using zsh shell
sudo usermod -s /bin/zsh johnc
# Add johnc to wheel group
sudo usermod -aG wheel johnc
# Setting password
if [ -z "$SKIP_SETTING_USER" ]; then
  sudo passwd johnc
else
  echo 'Skipped setting password';
fi
