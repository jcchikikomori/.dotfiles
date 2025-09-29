#!/bin/sh

# Unlocking SteamOS rootfs...
sudo steamos-readonly disable

# Install bare minimum packages...
sudo pacman -S --noconfirm --noprogressbar stow tmux tmuxp

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
