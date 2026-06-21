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

  if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    printf '%s\n' "darwin"
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

check_submodules() {
  if [ ! -f "$DOTFILES_PATH/.gitmodules" ]; then
    return 0
  fi

  # Check each submodule defined in .gitmodules
  for submodule_path in $(grep '^[[:space:]]*path=' "$DOTFILES_PATH/.gitmodules" | sed 's/^[[:space:]]*path=//'); do
    if [ ! -d "$submodule_path" ]; then
      continue
    fi
    if [ -f "$submodule_path/.git" ]; then
      gitdir_ref=$(cat "$submodule_path/.git" 2>/dev/null)
      if ! echo "$gitdir_ref" | grep -q "^gitdir:"; then
        log_error "Error: submodule '$submodule_path' is not properly initialized."
        log_error "Run: git submodule update --init --recursive"
        return 1
      fi
    else
      log_error "Error: submodule '$submodule_path' is empty or not initialized."
      log_error "Run: git submodule update --init --recursive"
      return 1
    fi
  done

  return 0
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

  if [ -x "/opt/homebrew/bin/dotstow" ]; then
    printf '%s\n' "/opt/homebrew/bin/dotstow"
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

# Guard: ensure submodules are initialized before stowing
if ! check_submodules; then
  log_error "Submodule check failed. Please initialize submodules first."
  log_error "Run: git submodule update --init --recursive"
  exit 1
fi

# Handle ~/.profile conflict before stowing
# If ~/.profile exists as a real file (not symlink), back it up
handle_profile_conflict() {
  local profile_file="$HOME/.profile"
  local backup_dir="$HOME/.backups"

  # Only act if ~/.profile exists and is NOT a symlink
  if [ -f "$profile_file" ] && [ ! -L "$profile_file" ]; then
    # Create backup directory if needed
    if [ ! -d "$backup_dir" ]; then
      mkdir -p "$backup_dir"
    fi

    # Backup with timestamp
    local timestamp
    timestamp="$(date +%Y%m%d-%H%M%S)"
    local backup_file="$backup_dir/.profile.backup.$timestamp"

    printf 'Backing up existing ~/.profile to %s\n' "$backup_file"
    cp -a "$profile_file" "$backup_file"

    # Remove the original so stow can create symlink
    rm "$profile_file"
    printf 'Removed original ~/.profile (stow will replace with symlink)\n'
  fi
}

if ! sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-cleanup"; then
  log_error "Error: dotfiles-cleanup failed."
  restore_external_symlinks
  exit 1
fi

if ! sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-cleanup-bin"; then
  log_error "Error: dotfiles-cleanup-bin failed."
  restore_external_symlinks
  exit 1
fi

if ! sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-ssh"; then
  log_error "Error: dotfiles-ssh failed."
  restore_external_symlinks
  exit 1
fi

if ! sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-conflicts"; then
  log_error "Error: conflict helper failed."
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

# Handle ~/.profile conflict before stowing
handle_profile_conflict

# darwin excludes Linux-only packages (dxvk, flatpak, wireplumber, lindbergh)
# bash package also excluded: macOS default shell is zsh and bash configs reference Linux-specific paths
if [ "$DETECTED_DISTRO" = "darwin" ]; then
  STOW_PACKAGES="zsh git antigen tmux tmuxp vim vscode systems python alacritty flags supermodel starship opencode claude"
else
  STOW_PACKAGES="bash zsh git antigen tmux tmuxp vim vscode dxvk systems python flatpak alacritty wireplumber flags lindbergh supermodel starship opencode claude"
fi
if ! "$DOTSTOW_BIN" stow $STOW_PACKAGES; then
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

# Remind user about EmuDeck sync setup if emudecktools package was stowed.
if [ "$DETECTED_DISTRO" != "darwin" ] && [ "$DETECTED_DISTRO" != "termux" ]; then
  printf '\n'
  printf 'Note: If you stowed the emudecktools package,\n'
  printf 'run the following to setup automatic syncing with systemd timer:\n'
  printf '  dotfiles-emudeck\n'
  printf '\n'
  printf 'Note: If you use AI coding agents (OpenCode or Claude Code),\n'
  printf 'run the following to sync shared skills and instructions:\n'
  printf '  devtools-opencode sync\n'
  printf '\n'
  printf 'For OpenCode, install MCP server binaries (pipx, npx, etc.):\n'
  printf '  devtools-opencode mcp install\n'
fi

exit 0
