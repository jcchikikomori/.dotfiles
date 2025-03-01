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
sudo apt-get install -y python3 zip unzip vi nano openssh ccache xsel ncdu wget

# SSH Keys
ssh-keygen -t ed25519 -C "jccorsanes@protonmail.com" -f $HOME/.ssh/id_ed25519 -N ""
ssh-keygen -t rsa -b 4096 -C "jccorsanes@protonmail.com" -f $HOME/.ssh/id_rsa -N ""

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
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please execute post-setup.sh to complete the setup."
else
  echo "Setup Completed. Please execute post-setup.sh to complete the setup."
fi

echo 'Script execution completed.'
