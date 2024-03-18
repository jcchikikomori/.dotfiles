#!/bin/sh

# WSL-related setup
# Note: Will take effect on next boot
echo "[boot]
systemd=true
[user]
default=johnc" | sudo tee /etc/wsl.conf

# Setting default locale
sudo loadkeys us
sudo sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' /etc/locale.gen
sudo locale-gen en_US.UTF-8
sudo localectl set-locale LANG=en_US.UTF-8

# Installing essentials (additional)
sudo apt-get install -y python3 zip unzip vi nano openssh ccache

# SSH Keys
ssh-keygen -t ed25519 -C "jccorsanes@protonmail.com" -f $HOME/.ssh/id_ed25519 -N ""
ssh-keygen -t rsa -b 4096 -C "jccorsanes@protonmail.com" -f $HOME/.ssh/id_rsa -N ""

# New method on setting up systemctl
# Source: https://github.com/nullpo-head/wsl-distrod
# if [ -n "$WSL_DISTRO_NAME" ]; then
#     curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
#     chmod +x install.sh
#     sudo ./install.sh install

#     # If you want to automatically start your distro on Windows startup, enable distrod by the following command
#     #/opt/distrod/bin/distrod enable --start-on-windows-boot
#     # Otherwise
#     /opt/distrod/bin/distrod enable
# fi

# Programming languages
if [ -v SKIP_INSTALL_PROGLANG ]; then
  echo 'Skipped installing programming languages.';
else
  sudo apt-get install -y ruby-build
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
