#!/bin/sh

echo 'Installing dependencies from system...'
sudo dnf groupinstall -y 'Development Tools'
sudo dnf install -y gcc-c++ make
sudo dnf install -y vim nano htop iftop stow git zsh unzip
sudo dnf install -y python2 python3 libssh-devel libgcrypt libgcrypt-devel
sudo dnf install -y python3-tmuxp

# Programming languages
if [ -v SKIP_SETTING_USER ]; then
  echo 'Skipped installing programming languages.';
else
  sudo dnf install -y ruby-build
  sudo -u admin bash -c '\
   pyenv install 3.11.4 -v
   pyenv global 3.11.4
   nvm install 18 --lts
  '
fi

echo 'Installing dependencies into your home directory...'
cd ..
./post-setup.sh

echo 'Script execution completed.'
