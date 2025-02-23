#!/bin/sh

# Check if a username is provided as an argument
if [ -n "$1" ]; then
  USERNAME=$1
else
  USERNAME=$(whoami)
  if [ "$USERNAME" = "root" ]; then
    USERNAME="johnc"
  fi
fi

# Create non root user
sudo useradd $USERNAME -m
# Using zsh shell
sudo usermod -s /bin/zsh johnc
# Add johnc to wheel group
sudo usermod -aG wheel johnc
# Setting password
confirm_and_set_password() {
  read -p "Do you want to set a password for $USERNAME? (y/n): " confirm
  if [ "$confirm" = "y" ]; then
    sudo passwd $USERNAME
  else
    echo 'Skipped setting password';
  fi
}

if [ -z "$SKIP_SETTING_USER" ]; then
  confirm_and_set_password
fi
else
  echo 'Skipped setting password';
fi
