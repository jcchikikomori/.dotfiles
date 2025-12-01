#!/bin/sh

echo "Welcome! Beginning setup..."

prelim() {
  echo "Copying/generating files needed to your home directory..."

  export DOTFILES_PATH=$(pwd)
  echo $DOTFILES_PATH >>.currentdir

  export DOTFILES_USERNAME=$(whoami)
  echo $DOTFILES_USERNAME >>.currentuser

  # mkdir -p $HOME/.local/bin/org.jcchikikomori.dotfiles/bin
  # echo "Copying scripts to ~/bin..."
  # cp -rf ./linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/* $HOME/.local/bin/org.jcchikikomori.dotfiles/bin/

  echo "Preliminary setup done! Proceeding with the rest of the setup..."
}

# Generate .bashrc from system (/etc/skel/.bashrc)
generate_bashrc() {
  echo "Generating .bashrc from system..."
  if [ -f /etc/skel/.bashrc ]; then
    cp -f /etc/skel/.bashrc $HOME/.bashrc
    echo "Generated .bashrc from system."
  else
    echo "System .bashrc not found. Skipping generation."
  fi
}

# Execute preliminary setup
generate_bashrc
prelim

# OS-related workarounds
export DETECTED_DISTRO="unknown"
# Ensure config directory exists
mkdir -p $HOME/.config
touch $HOME/.dotfiles-distro

# Check for Termux environment first (before /etc/os-release)
if [ -n "$PREFIX" ] && [ -d "$PREFIX" ] && echo "$PREFIX" | grep -q "com.termux"; then
  echo "You are using Termux (Android)"
  export DETECTED_DISTRO="termux"
  echo $DETECTED_DISTRO >> $HOME/.dotfiles-distro
# begin detection
elif [ -f /etc/os-release ]; then
  . /etc/os-release
  case $ID in
  ubuntu)
    echo "You are using Ubuntu"
    export DETECTED_DISTRO="ubuntu"
    echo $DETECTED_DISTRO >> $HOME/.dotfiles-distro
    ;;
  debian)
    echo "You are using Debian"
    export DETECTED_DISTRO="debian"
    export DEBIAN_FRONTEND=noninteractive
    echo $DETECTED_DISTRO >> $HOME/.dotfiles-distro
    ;;
  arch|garuda|manjaro|cachyos)
    if [[ $NAME == *"Arch Linux"* ]]; then
      echo "You are using Arch Linux Barebones"
      export DETECTED_DISTRO="archbtw"
    else
      echo "You are using Arch Linux"
      export DETECTED_DISTRO="arch"
    fi
    export MAKEFLAGS="-j$(nproc)"
    echo $DETECTED_DISTRO >> $HOME/.dotfiles-distro
    ;;
  steamos)
    echo "You are using SteamOS"
    export DETECTED_DISTRO="steamos"
    echo $DETECTED_DISTRO >> $HOME/.dotfiles-distro
    ;;
  fedora|centos|rhel)
    echo "You are using Fedora/CentOS/RHEL"
    # Ensure include the installed libraries from system before compiling software
    export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH}"
    # Ensure path for GO programming language
    export GOPATH="${HOME}/go"
    export DETECTED_DISTRO="rhel"
    echo $DETECTED_DISTRO >> $HOME/.dotfiles-distro
    ;;
  bazzite)
    echo "You are using Bazzite Linux. Please install using distrobox. Exiting..."
    exit 1
    ;;
  *)
    echo "You are using Unknown OS. Exiting..."
    exit 1
    ;;
  esac
elif [ -f /etc/redhat-release ]; then
  echo "You are using $(cat /etc/redhat-release)"
  export DETECTED_DISTRO="rhel"
elif [ -f /etc/debian_version ]; then
  echo "You are using Debian-based distro"
  export DETECTED_DISTRO="debian"
else
  echo "Unable to identify the OS. Exiting..."
  exit 1
fi

if [ -n "$DETECTED_DISTRO" ]; then
  echo "Detected distro: $DETECTED_DISTRO"
  case $DETECTED_DISTRO in
  termux)
    echo "Executing Termux-related workarounds..."
    sh termux/setup.sh
    sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup
    sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-bash install
    ;;
  debian)
    echo "Executing Debian-related workarounds..."
    sh debian/setup.sh
    sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup
    ;;
  ubuntu)
    echo "Executing Ubuntu-related workarounds..."
    sh ubuntu/setup.sh
    sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup
    ;;
  archbtw)
    echo "Executing Arch-related (btw) workarounds..."
    if [ -n "$CI" ]; then
      echo "Executing init.sh (CI/CD mode)..."
      sh arch/init.sh
    elif [ "$(id -u)" -ne 0 ]; then
      echo "Executing init.sh as root..."
      sudo sh arch/init.sh
    fi
    sh arch/setup.sh
    sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup
    ;;
  arch)
    echo "Executing Arch-related workarounds..."
    sh arch/setup.sh
    sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup
    ;;
  steamos)
    echo "Executing SteamOS-related workarounds..."
    sh steamos/setup.sh
    sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup
    sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-bash install
    ;;
  rhel)
    echo "Executing RHEL-related workarounds..."
    sh rhel/setup.sh
    echo "Installing VSCode..."
    sh rhel/vscode.sh
    sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup
    ;;
  *)
    echo "Unable to identify the distro to begin! Exiting..."
    exit 1
    ;;
  esac
else
  echo "Unable to identify the distro. Exiting..."
  exit 1
fi
