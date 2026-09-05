#!/bin/sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_PATH="$SCRIPT_DIR"
DOTFILES_BIN_DEFAULT="$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin"
DOTFILES_BIN_RESOLVED="${DOTFILES_BIN:-$DOTFILES_BIN_DEFAULT}"

if [ ! -r "$DOTFILES_BIN_RESOLVED/dotfiles-lib-output" ]; then
  echo "[dotfiles:stowme] Error: dotfiles-lib-output not found"
  exit 1
fi

# shellcheck source=/dev/null
. "$DOTFILES_BIN_RESOLVED/dotfiles-lib-output"

STOWME_VERBOSE=0
DISTRO_ARG=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --verbose|-v)
      STOWME_VERBOSE=1
      ;;
    *)
      if [ -z "$DISTRO_ARG" ]; then
        DISTRO_ARG="$1"
      fi
      ;;
  esac
  shift
done

DF_PREFIX="stowme"
if [ "$STOWME_VERBOSE" -eq 1 ]; then
  df_output_init --verbose
else
  df_output_init
fi

run_step() {
  label="$1"
  shift
  df_step "$label"
  if "$@"; then
    df_step_end 0
    return 0
  fi
  code=$?
  df_step_end "$code"
  return "$code"
}

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

DETECTED_DISTRO=$(detect_distro "$DISTRO_ARG")

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
        df_error "submodule '$submodule_path' is not properly initialized"
        df_error "Run: git submodule update --init --recursive"
        return 1
      fi
    else
      df_error "submodule '$submodule_path' is empty or not initialized"
      df_error "Run: git submodule update --init --recursive"
      return 1
    fi
  done

  return 0
}

# Guard: purge a stale vscode extensions.json leftover from the package source tree.
# GitHub #229: linux/vscode/.vscode-server/extensions/extensions.json used to be
# tracked in git until PR #211 removed it (dotfiles-cleanup now restores it as a
# real, non-stowed file on the $HOME side, since VS Code Server rewrites it
# constantly and it's machine-specific). Clones that had a locally-modified copy
# of the file at the time PR #211 landed keep a stray, gitignored copy behind in
# the package source tree. That stray file collides with the real file
# dotfiles-cleanup restores at $HOME/.vscode-server/extensions/extensions.json and
# makes `stow` abort the entire run with:
#   "existing target is neither a link nor a directory: .vscode-server/extensions/extensions.json"
cleanup_stray_vscode_extensions() {
  stray_extensions_dir="$DOTFILES_PATH/linux/vscode/.vscode-server/extensions"

  if [ ! -e "$stray_extensions_dir" ]; then
    return 0
  fi

  backup_dir="$HOME/.backups"
  mkdir -p "$backup_dir"
  timestamp=$(date +%Y%m%d-%H%M%S)
  cp -a "$stray_extensions_dir" "$backup_dir/vscode-extensions-stray.$timestamp"
  rm -rf "$stray_extensions_dir"
  df_ok "Removed stray $stray_extensions_dir (backed up to $backup_dir/vscode-extensions-stray.$timestamp)"
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
  df_error "Submodule check failed. Please initialize submodules first."
  df_error "Run: git submodule update --init --recursive"
  exit 1
fi

# Guard: remove stale vscode extensions.json leftover from the package source (#229)
cleanup_stray_vscode_extensions

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

if ! run_step "Running dotfiles-cleanup" df_run sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-cleanup"; then
  df_error "dotfiles-cleanup failed"
  restore_external_symlinks
  exit 1
fi

if ! run_step "Running dotfiles-cleanup-bin" df_run sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-cleanup-bin"; then
  df_error "dotfiles-cleanup-bin failed"
  restore_external_symlinks
  exit 1
fi

if ! run_step "Running dotfiles-ssh" df_run sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-ssh"; then
  df_error "dotfiles-ssh failed"
  restore_external_symlinks
  exit 1
fi

if ! run_step "Running dotfiles-conflicts" df_run sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-conflicts"; then
  df_error "conflict helper failed"
  restore_external_symlinks
  exit 1
fi

cd "$HOME" || exit 1

# Fedora/RHEL workaround for stow command path lookup through libgcrypt.
if [ "$DETECTED_DISTRO" = "rhel" ]; then
  export LD_PRELOAD="/usr/lib64/libgcrypt.so.20"
fi

if ! DOTSTOW_BIN=$(resolve_dotstow); then
  df_error "dotstow command not found in PATH or known install locations"
  if [ "$DETECTED_DISTRO" = "rhel" ]; then
    export LD_PRELOAD=
  fi
  restore_external_symlinks
  exit 1
fi

df_info "Stowing dotfiles for distro: $DETECTED_DISTRO"

# Handle ~/.profile conflict before stowing
handle_profile_conflict

# darwin excludes Linux-only packages (dxvk, flatpak, wireplumber, lindbergh)
# bash package also excluded: macOS default shell is zsh and bash configs reference Linux-specific paths
if [ "$DETECTED_DISTRO" = "darwin" ]; then
  STOW_PACKAGES="zsh git antigen tmux tmuxp vim neovim vscode systems python alacritty flags supermodel starship opencode claude"
else
  STOW_PACKAGES="bash zsh git antigen tmux tmuxp vim neovim vscode dxvk systems python flatpak mpv alacritty wireplumber flags lindbergh supermodel starship opencode claude"
fi

# Termux gets no Neovim: no dotfiles-neovim installer is ever run there,
# and LazyVim's version floor is out of scope for Termux's Bionic libc.
if [ "$DETECTED_DISTRO" = "termux" ]; then
  _filtered_packages=""
  for _pkg in $STOW_PACKAGES; do
    [ "$_pkg" = "neovim" ] && continue
    _filtered_packages="$_filtered_packages $_pkg"
  done
  STOW_PACKAGES=${_filtered_packages# }
fi
if ! run_step "Stowing dotfiles packages" df_run "$DOTSTOW_BIN" stow $STOW_PACKAGES; then
  df_error "dotstow stow failed"
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

if [ -f "$HOME/.local/share/devtools-opencode/omos.prefs" ] && command -v devtools-opencode > /dev/null 2>&1; then
  df_info "Restoring oh-my-opencode-slim configuration..."
  devtools-opencode omos restore
fi

# Remind user about EmuDeck sync setup if emudecktools package was stowed.
if [ "$DETECTED_DISTRO" != "darwin" ] && [ "$DETECTED_DISTRO" != "termux" ]; then
  df_info "Note: If you stowed the emudecktools package, run: dotfiles-emudeck"
  df_info "Note: If you use AI coding agents, run: devtools-opencode sync"
  df_info "For OpenCode MCP binaries, run: devtools-opencode mcp install"
fi

exit 0
