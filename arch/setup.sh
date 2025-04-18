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
sudo pacman -S --noconfirm --noprogressbar base-devel git python3 zip unzip vi nano fakeroot openssh stow sqlite tmux wget
mkdir -p temp && cd temp/
# Reference: https://devicetests.com/running-commands-non-root-user-sudo
sudo -u johnc bash -c '\
 git clone https://aur.archlinux.org/yay.git $HOME/yay
 cd $HOME/yay && makepkg -si --noconfirm
'
cd ../..
rm -rf temp/

# SSH Keys
# ssh-keygen -t ed25519 -C "jccorsanes@protonmail.com" -f $HOME/.ssh/id_ed25519 -N ""
# ssh-keygen -t rsa -b 4096 -C "jccorsanes@protonmail.com" -f $HOME/.ssh/id_rsa -N ""

# Chaotic AUR
echo 'Importing essential keys...'
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
echo 'Signing keys...'
sudo pacman-key --lsign-key 3056513887B78AEB
echo 'Begin installing Chaotic AUR...'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
# Backup the pacman.conf file
sudo cp -f /etc/pacman.conf /etc/pacman.conf.bak
# Add the Chaotic AUR repository to pacman.conf without manual confirmation
echo "
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
# Synchronize and upgrade packages without manual confirmation
sudo pacman -Syyu --noconfirm --noprogressbar

# Compilation Cache
sudo pacman -S --noconfirm --noprogressbar ccache

# NVM
sudo pacman -S --noconfirm --noprogressbar chaotic-aur/nvm

# Workarounds & Misc software
sudo pacman -S --noconfirm --noprogressbar aur/pam_ssh_agent_auth
sudo pacman -S --noconfirm --noprogressbar xsel ncdu

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please execute post-setup.sh to complete the setup."
else
  echo 'Please install dependencies into your home directory...'
  echo 'Execute: dotfiles-post-setup'
fi

echo 'Script execution completed.'
