#!/bin/sh

# Install essentials
sudo pacman -Syyu --noconfirm --noprogressbar
sudo pacman -S --noconfirm --noprogressbar base-devel git python3
mkdir -p temp && cd temp/
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ../../
rm -rf temp/

# Install Chaotic-AUR
sudo pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
sudo pacman-ket --init
sudo pacman-key --lsign-key FBA220DFC880C036
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# New method on setting up systemctl
# Source: https://github.com/nullpo-head/wsl-distrod
curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
chmod +x install.sh
sudo ./install.sh install
rm -f install.sh

# If you want to automatically start your distro on Windows startup, enable distrod by the following command
#/opt/distrod/bin/distrod enable --start-on-windows-boot
# Otherwise
/opt/distrod/bin/distrod enable

# always put this oh-my-zsh into the end
yay -S --noconfirm --noprogressbar rbenv tmux starship antigen oh-my-zsh-git
