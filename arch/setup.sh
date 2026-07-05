#!/bin/sh

# Source shared pacman install helper
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/../linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-pacman-install"

# Setting default locale
sudo loadkeys us
sudo sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' /etc/locale.gen
sudo locale-gen en_US.UTF-8
sudo localectl set-locale LANG=en_US.UTF-8

# Install essentials
pacman_install "-Syyu --noconfirm --noprogressbar" nano htop iftop mtr dkms lz4 bash-completion base-devel pacman-contrib git zsh unzip
pacman_install "-S --noconfirm --noprogressbar" base-devel python3 zip unzip vi nano fakeroot openssh stow sqlite tmux wget entr less

# AUR repository setup, yay installation, and AUR packages are now handled by
# the dotfiles-arch utility. Run `dotfiles-arch setup` after this script.

# Compilation Cache
pacman_install "-S --noconfirm --noprogressbar" ccache

# Workarounds & Misc software
pacman_install "-S --noconfirm --noprogressbar" xclip
# Install mirror management tools
pacman_install "-S --noconfirm --noprogressbar" rankmirrors reflector

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  echo "Setup Completed."
  echo "Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
fi

exit 0
