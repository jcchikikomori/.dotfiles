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

# Install essentials
sudo pacman -Syyu --noconfirm --noprogressbar
sudo pacman -S --noconfirm --noprogressbar base-devel git python3 zip unzip vi nano fakeroot openssh stow sqlite
mkdir -p temp && cd temp/
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ../..
rm -rf temp/

# SSH Keys
ssh-keygen -t ed25519 -C "jccorsanes@protonmail.com" || true
ssh-keygen -t rsa -b 4096 -C "jccorsanes@protonmail.com" || true

# Chaotic AUR
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee /etc/pacman.conf

# Compilation Cache
sudo pacman -S --noconfirm --noprogressbar ccache

# NVM
sudo pacman -S --noconfirm --noprogressbar chaotic-aur/nvm

# Workarounds & Misc software
sudo pacman -S --noconfirm --noprogressbar aur/pam_ssh_agent_auth

# Programming languages
sudo pacman -S --noconfirm --noprogressbar pyenv rbenv chaotic-aur/nvm
pyenv install 3.11.4 -v
pyenv global 3.11.4
nvm install 18 --lts
npm install -g dotstow

# Programming languages: SDKMAN
curl -s "https://get.sdkman.io" | bash

echo 'Installing dependencies into your home directory...'
cd ..
./post-setup.sh

echo 'Script execution completed.'
