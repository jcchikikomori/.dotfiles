#!/bin/sh

# Unlocking SteamOS rootfs...
sudo steamos-readonly disable

# Install essentials
sudo pacman -Syy --noconfirm --noprogressbar gvim nano htop iftop mtr dkms lz4 bash-completion base-devel pacman-contrib git zsh unzip \
  base-devel python3 zip unzip vi nano fakeroot openssh stow sqlite tmux wget

# Workarounds & Misc software
sudo pacman -S --noconfirm --noprogressbar xsel ncdu

# Locking SteamOS rootfs...
sudo steamos-readonly enable

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  echo "Setup Completed."
  echo 'Please install dependencies into your home directory (Execute: dotfiles-post-setup).'
fi

exit 0
