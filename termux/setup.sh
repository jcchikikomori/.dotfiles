#!/bin/sh

# Init setup
# Note: dkms, lz4, sqlite3, ccache are not available in Termux
# Note: vim-gtk3 (gvim) is not available in Termux
# Note: Additional build dependencies may not be available in Termux
# Change mirrors first based on your location
# Note: Execute `export TERM=xterm-256color` if you face any terminal issues
export TERM=xterm-256color
termux-change-repo
pkg update

pkg install -y apt ca-certificates curl
pkg install -y stow vim nano htop git zsh build-essential which
pkg install -y python zip openssh ncdu wget tmux unzip

# Setting default locale
# Termux does not use loadkeys or localectl, locale settings are managed differently
# Workaround: termux-reload-settings may fail with app_process errors in some environments
termux-reload-settings 2>/dev/null || echo "Warning: termux-reload-settings not available, skipping..."
sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' $PREFIX/etc/locale.gen
locale-gen en_US.UTF-8
export LANG=en_US.UTF-8

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  echo "Setup Completed."
  echo 'Please install dependencies into your home directory (Execute: dotfiles-post-setup).'
fi

echo 'Script execution completed.'
