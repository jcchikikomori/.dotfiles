#!/bin/sh

echo 'Installing dependencies from system...'
sudo dnf groupinstall 'Development Tools'
sudo dnf install gcc-c++ make
sudo dnf install -y vim vi nano git zsh
sudo dnf install -y python2 python3 libssh-devel libgcrypt libgcrypt-devel
sudo dnf install -y python3-tmuxp

echo 'Installing dependencies into your home directory...'
cd ..
./post-setup.sh

echo 'Script execution completed.'
