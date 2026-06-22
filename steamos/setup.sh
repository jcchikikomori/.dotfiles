#!/bin/sh

# Space-separated package list to force install on file conflicts.
# Example: PACMAN_FORCE_CONFLICT_PACKAGES="python3 openssh" sh ./steamos/setup.sh
PACMAN_FORCE_CONFLICT_PACKAGES="${PACMAN_FORCE_CONFLICT_PACKAGES:-}"
PACMAN_OVERWRITE_GLOB="${PACMAN_OVERWRITE_GLOB:-*}"

is_forced_package() {
  package_name="$1"
  for forced_pkg in $PACMAN_FORCE_CONFLICT_PACKAGES; do
    if [ "$forced_pkg" = "$package_name" ]; then
      return 0
    fi
  done
  return 1
}

pacman_install() {
  pacman_args="$1"
  shift

  regular_packages=""
  forced_packages=""

  for package_name in "$@"; do
    if is_forced_package "$package_name"; then
      forced_packages="$forced_packages $package_name"
    else
      regular_packages="$regular_packages $package_name"
    fi
  done

  if [ -n "$regular_packages" ]; then
    sudo pacman $pacman_args $regular_packages || return 1
  fi

  if [ -n "$forced_packages" ]; then
    echo "Installing forced packages with overwrite glob: $PACMAN_OVERWRITE_GLOB"
    sudo pacman $pacman_args --overwrite "$PACMAN_OVERWRITE_GLOB" $forced_packages || return 1
  fi
}

# Unlocking SteamOS rootfs...
sudo steamos-readonly disable

# Initialize pacman keyring (required for SteamOS 3.5+ to trust Valve's signing keys)
echo "Initializing pacman keyring..."
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman-key --populate holo 2>/dev/null || true

# Chaotic AUR
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
  echo 'Importing Chaotic AUR keys...'
  echo "y" | sudo pacman-key --recv-key 3056513887B78AEB --keyserver hkp://keyserver.ubuntu.com:80
  echo 'Signing Chaotic AUR keys...'
  echo "y" | sudo pacman-key --lsign-key 3056513887B78AEB
  echo 'Installing Chaotic AUR keyring and mirrorlist...'
  sudo pacman -U --noconfirm --noprogressbar 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  sudo cp -f /etc/pacman.conf /etc/pacman.conf.bak
  echo "
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
  sudo pacman -Syy --noconfirm --noprogressbar
else
  echo "chaotic-aur repository is already registered. Skipping..."
fi

# CachyOS Repository
if ! grep -q "\[cachyos-v3\]" /etc/pacman.conf; then
  echo 'Importing CachyOS keys...'
  echo "y" | sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
  echo 'Signing CachyOS keys...'
  echo "y" | sudo pacman-key --lsign-key F3B607488DB35A47
  echo 'Installing CachyOS keyring and mirrorlist...'
  sudo pacman -U --noconfirm \
    'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
    'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-27-1-any.pkg.tar.zst' \
    'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-27-1-any.pkg.tar.zst' \
    'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v4-mirrorlist-27-1-any.pkg.tar.zst'
  sudo cp -f /etc/pacman.conf /etc/pacman.conf.bak
  echo "
[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos-core-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos-extra-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
" | sudo tee -a /etc/pacman.conf
  sudo pacman -Syy --noconfirm --noprogressbar
else
  echo "CachyOS repository is already registered. Skipping..."
fi

# Install CachyOS packages
pacman_install "-S --noconfirm --noprogressbar" dmemcg-booster kcgroups plasma-foreground-booster

# Install essentials
pacman_install "-Syy --noconfirm --noprogressbar" nano htop iftop mtr dkms lz4 bash-completion base-devel pacman-contrib git zsh unzip \
  base-devel python3 zip unzip vi nano fakeroot openssh stow sqlite tmux wget entr

# Install yay (AUR helper)
if ! command -v yay >/dev/null 2>&1; then
  echo "Installing yay..."
  tmp_dir=$(mktemp -d)
  cd "$tmp_dir"
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  git checkout 7d1b1a155500987cd7684a4b2afd76a98b6ed922
  makepkg -si --noconfirm
  cd /
  rm -rf "$tmp_dir"
  echo "yay installed successfully"
else
  echo "yay is already installed"
fi

# Install AUR packages
yay -S --noconfirm podman-docker-git

# Workarounds & Misc software
pacman_install "-S --noconfirm --noprogressbar" xsel ncdu

# Installing rclone
pacman_install "-S --noconfirm --noprogressbar" rclone

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
