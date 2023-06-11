#!/bin/sh

sudo dnf groupinstall 'Development Tools'
sudo dnf install gcc-c++ make
sudo dnf in -y git zsh
sudo dnf in -y python2 python3 libssh-devel libgcrypt libgcrypt-devel

curl -sS https://starship.rs/install.sh | sh
curl -L git.io/antigen >$HOME/antigen.zsh

# always put this oh-my-zsh into the end
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
