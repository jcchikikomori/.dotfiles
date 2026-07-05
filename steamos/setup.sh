#!/bin/sh

# Source shared pacman install helper
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_BIN="$SCRIPT_DIR/../linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin"
. "$DOTFILES_BIN/dotfiles-pacman-install"

# Unlocking SteamOS rootfs...
sudo steamos-readonly disable

# Initialize pacman keyring (SteamOS 3.5+ requires holo keyring for Valve-signed
# packages). Use dotfiles-steamdeck's fix-keyring, not dotfiles-arch's: the Arch
# version early-returns whenever any key already exists (true on SteamOS, which
# ships with holo keys pre-populated) and never runs --populate archlinux.
"$DOTFILES_BIN/dotfiles-steamdeck" fix-keyring

# Setup third-party repositories (Chaotic AUR + CachyOS)
"$DOTFILES_BIN/dotfiles-arch" setup-repositories

# Install essential packages from standard pacman repos (needed before
# install-yay, which requires git + base-devel). Repos were just refreshed
# above, so -S --needed is enough here.
pacman_install "-S --needed --noconfirm --noprogressbar" \
  nano htop iftop mtr dkms lz4 bash-completion base-devel pacman-contrib \
  git zsh unzip python3 zip vi fakeroot openssh stow sqlite tmux wget entr less

# Install AUR helper, then mandatory + optional edge packages
"$DOTFILES_BIN/dotfiles-arch" install-yay
"$DOTFILES_BIN/dotfiles-arch" install-packages
"$DOTFILES_BIN/dotfiles-arch" install-packages-edge

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
