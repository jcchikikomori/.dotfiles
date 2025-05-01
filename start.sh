#!/bin/sh

echo "Welcome! Beginning setup..."

prelim() {
  echo "Copying files needed to your home directory..."
  cp .pythonversion $HOME/.dotfiles-python-version

  export DOTFILES_PATH=$(pwd)
  echo $DOTFILES_PATH >> .currentdir

  export DOTFILES_USERNAME=$(whoami)
  echo $DOTFILES_USERNAME >> .currentuser

  # mkdir -p $HOME/bin
  # echo "Copying scripts to ~/bin..."
  # cp -rf ./linux/zsh/bin/* $HOME/bin/

  echo "Preliminary setup done! Proceeding with the rest of the setup..."
}

# OS-related workarounds
export DETECTED_DISTRO="unknown"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  case $ID in
  ubuntu)
    echo "You are using Ubuntu"
    export DETECTED_DISTRO="ubuntu"
    ;;
  debian)
    echo "You are using Debian"
    export DETECTED_DISTRO="debian"
    ;;
  arch)
    if [[ $NAME == *"Arch Linux"* ]]; then
      echo "You are using Arch Linux Barebones"
      export DETECTED_DISTRO="archbtw"
    else
      echo "You are using Arch Linux"
      export DETECTED_DISTRO="arch"
    fi
    ;;
  garuda)
    echo "You are using Garuda Linux"
    export DETECTED_DISTRO="arch"
    ;;
  manjaro)
    echo "You are using Manjaro"
    export DETECTED_DISTRO="arch"
    ;;
  fedora*)
    echo "You are using Fedora"
    # Ensure include the installed libraries from system before compiling software
    export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH}"
    # Ensure path for GO programming language
    export GOPATH="${HOME}/go"
    export DETECTED_DISTRO="rhel"
    ;;
  bazzite)
    echo "You are using Bazzite Linux. Please install using distrobox. Exiting..."
    exit 1
    ;;
  *)
    echo "You are using Unknown OS"
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

# Execute preliminary setup
prelim

if [ -n "$DETECTED_DISTRO" ]; then
  echo "Detected distro: $DETECTED_DISTRO"
  case $DETECTED_DISTRO in
  debian)
    echo "Executing Debian-related workarounds..."
    sh debian/setup.sh
    sh linux/zsh/bin/dotfiles-post-setup
    ;;
  ubuntu)
    echo "Executing Ubuntu-related workarounds..."
    sh ubuntu/setup.sh
    sh linux/zsh/bin/dotfiles-post-setup
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
    sh linux/zsh/bin/dotfiles-post-setup
    ;;
  arch)
    echo "Executing Arch-related workarounds..."
    sh arch/setup.sh
    sh linux/zsh/bin/dotfiles-post-setup
    ;;
  rhel)
    echo "Executing RHEL-related workarounds..."
    sh rhel/setup.sh
    echo "Installing VSCode..."
    sh rhel/vscode.sh
    sh linux/zsh/bin/dotfiles-post-setup
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
