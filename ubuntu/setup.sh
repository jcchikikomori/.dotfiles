#!/bin/sh

# Init setup
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo apt-get install -y stow vim nano htop iftop mtr dkms lz4 git zsh build-essential sqlite3 ccache tmux unzip

# Installing essentials (additional)
# NOTES:
# - vim-gtk3 = gvim
sudo apt-get install -y python3 zip vi openssh xsel ncdu wget vim-gtk3

# Setting default locale
sudo loadkeys us
sudo sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' /etc/locale.gen
sudo locale-gen en_US.UTF-8
sudo localectl set-locale LANG=en_US.UTF-8

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  echo "Setup Completed."
  echo 'Please install dependencies into your home directory (Execute: dotfiles-post-setup).'
fi

echo 'Script execution completed.'
