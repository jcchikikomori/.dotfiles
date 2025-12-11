#!/bin/sh

# Setting default locale
sudo loadkeys us
sudo sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' /etc/locale.gen
sudo locale-gen en_US.UTF-8
sudo localectl set-locale LANG=en_US.UTF-8

# Install essentials
sudo pacman -Syyu --noconfirm --noprogressbar gvim nano htop iftop mtr dkms lz4 bash-completion base-devel pacman-contrib git zsh unzip
sudo pacman -S --noconfirm --noprogressbar base-devel python3 zip unzip vi nano fakeroot openssh stow sqlite tmux wget less
# Ensure temp directory exists
mkdir -p temp && cd temp/
# Install yay
git clone https://aur.archlinux.org/yay.git $HOME/yay
cd $HOME/yay
makepkg -si --noconfirm
# Cleanup
cd ../..
rm -rf temp/

# Chaotic AUR
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
  echo 'Importing essential keys...'
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver hkp://keyserver.ubuntu.com:80
  echo 'Signing keys...'
  sudo pacman-key --lsign-key 3056513887B78AEB
  echo 'Begin installing Chaotic AUR...'
  sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  # Backup the pacman.conf file
  sudo cp -f /etc/pacman.conf /etc/pacman.conf.bak
  # Add the Chaotic AUR repository to pacman.conf
  echo "
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
  # Synchronize and upgrade packages
  sudo pacman -Syyu --noconfirm --noprogressbar
else
  echo "chaotic-aur repository is already registered. Skipping..."
fi

# Compilation Cache
sudo pacman -S --noconfirm --noprogressbar ccache

# Programming languages
sudo pacman -S --noconfirm --noprogressbar chaotic-aur/nvm
sudo pacman -S --noconfirm --noprogressbar rbenv pyenv
sudo pacman -S --noconfirm --noprogressbar aur/phpenv-git

# Workarounds & Misc software
sudo pacman -S --noconfirm --noprogressbar aur/pam_ssh_agent_auth
sudo pacman -S --noconfirm --noprogressbar xsel ncdu
# Install mirror management tools
sudo pacman -S --noconfirm --noprogressbar rankmirrors reflector

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  echo "Setup Completed."
  echo 'Please install dependencies into your home directory (Execute: dotfiles-post-setup).'
fi

exit 0
