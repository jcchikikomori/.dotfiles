#!/bin/sh

detect_distro() {
  if [ -n "$1" ]; then
    printf '%s\n' "$1"
    return 0
  fi

  if [ -f "$HOME/.dotfiles-distro" ]; then
    detected_from_file=$(tail -n 1 "$HOME/.dotfiles-distro" 2>/dev/null)
    if [ -n "$detected_from_file" ]; then
      printf '%s\n' "$detected_from_file"
      return 0
    fi
  fi

  if [ -n "$PREFIX" ] && [ -d "$PREFIX" ] && echo "$PREFIX" | grep -q "com.termux"; then
    printf '%s\n' "termux"
    return 0
  fi

  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "$ID" in
    ubuntu)
      printf '%s\n' "ubuntu"
      ;;
    debian)
      printf '%s\n' "debian"
      ;;
    arch | garuda | manjaro | cachyos)
      if echo "$NAME" | grep -q "Arch Linux"; then
        printf '%s\n' "archbtw"
      else
        printf '%s\n' "arch"
      fi
      ;;
    steamos)
      printf '%s\n' "steamos"
      ;;
    fedora | centos | rhel)
      printf '%s\n' "rhel"
      ;;
    *)
      printf '%s\n' "unknown"
      ;;
    esac
    return 0
  fi

  if [ -f /etc/redhat-release ]; then
    printf '%s\n' "rhel"
  elif [ -f /etc/debian_version ]; then
    printf '%s\n' "debian"
  else
    printf '%s\n' "unknown"
  fi
}

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_PATH="$SCRIPT_DIR"
DETECTED_DISTRO=$(detect_distro "$1")

sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-cleanup"
sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-ssh"

cd "$HOME" || exit 1

# Fedora/RHEL workaround for stow command path lookup through libgcrypt.
if [ "$DETECTED_DISTRO" = "rhel" ]; then
  export LD_PRELOAD="/usr/lib64/libgcrypt.so.20"
fi

dotstow stow bash zsh git antigen tmux tmuxp vim vscode dxvk systems python flatpak alacritty wireplumber flags lindbergh supermodel starship

if [ "$DETECTED_DISTRO" = "rhel" ]; then
  export LD_PRELOAD=
fi

exit 0
