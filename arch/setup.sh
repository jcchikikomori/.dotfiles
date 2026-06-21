#!/bin/sh

# Space-separated package list to force install on file conflicts.
# Example: PACMAN_FORCE_CONFLICT_PACKAGES="python3 openssh" sh ./arch/setup.sh
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
