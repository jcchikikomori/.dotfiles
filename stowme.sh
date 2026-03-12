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

if [ -t 1 ]; then
  COLOR_POSITIVE=$(printf '\033[0;32m')
  COLOR_NEGATIVE=$(printf '\033[0;31m')
  COLOR_RESET=$(printf '\033[0m')
else
  COLOR_POSITIVE=''
  COLOR_NEGATIVE=''
  COLOR_RESET=''
fi

log_positive() {
  printf '%s%s%s\n' "$COLOR_POSITIVE" "$1" "$COLOR_RESET"
}

log_error() {
  printf '%s%s%s\n' "$COLOR_NEGATIVE" "$1" "$COLOR_RESET" >&2
}

resolve_dotstow() {
  if command -v dotstow >/dev/null 2>&1; then
    command -v dotstow
    return 0
  fi

  if [ -x "$HOME/.local/bin/org.jcchikikomori.dotfiles/bin/dotstow" ]; then
    printf '%s\n' "$HOME/.local/bin/org.jcchikikomori.dotfiles/bin/dotstow"
    return 0
  fi

  if [ -x "/usr/local/bin/dotstow" ]; then
    printf '%s\n' "/usr/local/bin/dotstow"
    return 0
  fi

  return 1
}

# Some tools (AWS CLI, Azure CLI, GHCup) create $HOME/<dir> as an absolute symlink
# pointing outside $HOME (e.g. /mnt/c/... on WSL, /usr/local/... in CI). Stow
# cannot traverse these and throws "BUG in find_stowed_path". Remove them before
# ANY stow/unstow operation (including the cleanup unstow below) and restore after.
IS_WSL=0
if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
  IS_WSL=1
fi

if [ "$IS_WSL" = "1" ] && [ -L "$HOME/.aws" ]; then
  AWS_LINK_TARGET=$(readlink "$HOME/.aws")
  rm "$HOME/.aws"
fi

if [ "$IS_WSL" = "1" ] && [ -L "$HOME/.azure" ]; then
  AZURE_LINK_TARGET=$(readlink "$HOME/.azure")
  rm "$HOME/.azure"
fi

# GHCup symlinks ~/.ghcup -> /usr/local/.ghcup in many CI environments.
if [ -L "$HOME/.ghcup" ]; then
  GHCUP_LINK_TARGET=$(readlink "$HOME/.ghcup")
  rm "$HOME/.ghcup"
fi

restore_external_symlinks() {
  if [ "$IS_WSL" = "1" ] && [ -n "$AWS_LINK_TARGET" ]; then
    ln -s "$AWS_LINK_TARGET" "$HOME/.aws"
  fi
  if [ "$IS_WSL" = "1" ] && [ -n "$AZURE_LINK_TARGET" ]; then
    ln -s "$AZURE_LINK_TARGET" "$HOME/.azure"
  fi
  if [ -n "$GHCUP_LINK_TARGET" ]; then
    ln -s "$GHCUP_LINK_TARGET" "$HOME/.ghcup"
  fi
}

if ! sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-cleanup"; then
  log_error "Error: dotfiles-cleanup failed."
  restore_external_symlinks
  exit 1
fi

if ! sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-ssh"; then
  log_error "Error: dotfiles-ssh failed."
  restore_external_symlinks
  exit 1
fi

cd "$HOME" || exit 1

# Fedora/RHEL workaround for stow command path lookup through libgcrypt.
if [ "$DETECTED_DISTRO" = "rhel" ]; then
  export LD_PRELOAD="/usr/lib64/libgcrypt.so.20"
fi

if ! DOTSTOW_BIN=$(resolve_dotstow); then
  log_error "Error: dotstow command not found in PATH or known install locations."
  if [ "$DETECTED_DISTRO" = "rhel" ]; then
    export LD_PRELOAD=
  fi
  restore_external_symlinks
  exit 1
fi

log_positive "Stowing dotfiles for distro: $DETECTED_DISTRO"
if ! "$DOTSTOW_BIN" stow bash zsh git antigen tmux tmuxp vim vscode dxvk systems python flatpak alacritty wireplumber flags lindbergh supermodel starship; then
  log_error "Error: dotstow stow failed."
  if [ "$DETECTED_DISTRO" = "rhel" ]; then
    export LD_PRELOAD=
  fi
  restore_external_symlinks
  exit 1
fi

if [ "$DETECTED_DISTRO" = "rhel" ]; then
  export LD_PRELOAD=
fi

# Restore symlinks that were temporarily removed for stow compatibility.
restore_external_symlinks

exit 0
