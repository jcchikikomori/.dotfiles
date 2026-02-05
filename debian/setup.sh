#!/bin/sh

# Detect if running as root or need sudo (especially for WSL)
# This might be applied to any distro, but requires more testing.
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo "Error: This script requires root privileges or sudo." >&2
    echo "Please run as root or install sudo: apt install sudo" >&2
    exit 1
  fi
fi

# Init setup
$SUDO apt update
$SUDO apt install -y apt-transport-https ca-certificates curl software-properties-common

# Install kbd for loadkeys (console keyboard layout)
# Install gnupg for gpgconf and gpg-connect-agent commands
# Install locales for locale-gen
$SUDO apt install -y stow vim nano htop iftop mtr dkms lz4 git zsh build-essential sqlite3 ccache tmux unzip kbd gnupg locales

# Installing essentials (additional)
# NOTES:
# - vim-gtk3 = gvim
$SUDO apt install -y python3 zip vi openssh xsel ncdu wget vim-gtk3

# Installing additional packages (for building others such as pyenv)
$SUDO apt install -y libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Setting default locale (skip loadkeys on WSL as it doesn't support console keymaps)
if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
  echo "WSL detected: Skipping loadkeys (not supported in WSL)."
else
  if command -v loadkeys >/dev/null 2>&1; then
    $SUDO loadkeys us || echo "Warning: loadkeys failed, continuing..."
  fi
fi

$SUDO sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' /etc/locale.gen
$SUDO locale-gen en_US.UTF-8

# localectl may not work in containers or WSL, handle gracefully
if command -v localectl >/dev/null 2>&1; then
  $SUDO localectl set-locale LANG=en_US.UTF-8 2>/dev/null || echo "Warning: localectl set-locale failed (may not work in containers/WSL)."
fi

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  echo "Setup Completed."
  echo 'Please install dependencies into your home directory (Execute: dotfiles-post-setup).'
fi

echo 'Script execution completed.'
