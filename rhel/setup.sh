#!/bin/sh

echo 'Installing dependencies from system...'
sudo dnf groupinstall -y 'Development Tools'
sudo dnf install -y gcc-c++ make
sudo dnf install -y vim nano htop iftop stow git zsh unzip
sudo dnf install -y python2 python3 libssh-devel libgcrypt libgcrypt-devel
sudo dnf install -y python3-tmuxp

# Programming languages
if [ -v SKIP_INSTALL_PROGLANG ]; then
  echo 'Skipped installing programming languages.';
else
  sudo dnf install -y ruby-build
  sudo -u johnc bash -c '\
   pyenv install 3.11.4 -v
   pyenv global 3.11.4
   nvm install 18 --lts
  '
fi

# Post-Setup
if [ -v SKIP_POST_SETUP ]; then
  echo 'Skipped post-setup script.';
else
  echo 'Please install dependencies into your home directory...'
  echo 'Execute: dotfiles-dotstow-post-setup'
fi

echo 'Script execution completed.'
