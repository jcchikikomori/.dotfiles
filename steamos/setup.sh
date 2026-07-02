#!/bin/sh

# Clean up temp files on exit
CLEANUP_DIRS="/tmp/dotfiles-* /tmp/yay-*"
cleanup() {
  for dir in $CLEANUP_DIRS; do
    [ -d "$dir" ] && sudo rm -rf "$dir" 2>/dev/null || true
  done
}
trap cleanup EXIT

# Source shared pacman install helper
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_BIN="$SCRIPT_DIR/../linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin"
. "$DOTFILES_BIN/dotfiles-pacman-install"

# Unlocking SteamOS rootfs...
sudo steamos-readonly disable

# Initialize pacman keyring (SteamOS 3.5+ requires holo keyring for Valve-signed packages)
"$DOTFILES_BIN/dotfiles-arch" fix-keyring
sudo pacman-key --populate holo 2>/dev/null || true

# Setup third-party repositories (Chaotic AUR + CachyOS)
"$DOTFILES_BIN/dotfiles-arch" setup-repositories

# Install essential packages from standard pacman repos
pacman_install "-Syy --noconfirm --noprogressbar" \
  nano htop iftop mtr dkms lz4 bash-completion base-devel pacman-contrib \
  git zsh unzip python3 zip vi fakeroot openssh stow sqlite tmux wget entr less

# Install AUR helper and AUR packages
"$DOTFILES_BIN/dotfiles-arch" install-yay
"$DOTFILES_BIN/dotfiles-arch" install-packages

# Locking SteamOS rootfs...
sudo steamos-readonly enable

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  echo "Setup Completed."
  echo "Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
fi

exit 0
