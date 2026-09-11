#!/bin/sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_BIN="$SCRIPT_DIR/../linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin"

if [ ! -r "$DOTFILES_BIN/dotfiles-lib-output" ]; then
  echo "[dotfiles:steamos-setup] Error: dotfiles-lib-output not found" >&2
  exit 1
fi

# shellcheck source=/dev/null
. "$DOTFILES_BIN/dotfiles-lib-output"

STEAMOS_SETUP_VERBOSE=0
for arg in "$@"; do
  case "$arg" in
    --verbose|-v)
      STEAMOS_SETUP_VERBOSE=1
      ;;
  esac
done

DF_PREFIX="steamos-setup"
if [ "$STEAMOS_SETUP_VERBOSE" -eq 1 ]; then
  df_output_init --verbose
  export DOTFILES_VERBOSE=1
else
  df_output_init
fi

. "$DOTFILES_BIN/dotfiles-pacman-install"

run_step() {
  label="$1"
  shift
  df_step "$label"
  if "$@"; then
    code=0
  else
    code=$?
  fi
  # df_step_end returns the effective status: non-zero when $code is non-zero
  # OR when a df_run inside the step failed but the command swallowed it.
  df_step_end "$code"
  return "$?"
}

# Unlocking SteamOS rootfs...
run_step "Unlocking SteamOS rootfs" df_run sudo steamos-readonly disable || df_fail "Failed to disable steamos-readonly"

# Initialize pacman keyring (SteamOS 3.5+ requires holo keyring for Valve-signed
# packages). Use dotfiles-steamdeck's fix-keyring, not dotfiles-arch's: the Arch
# version early-returns whenever any key already exists (true on SteamOS, which
# ships with holo keys pre-populated) and never runs --populate archlinux.
run_step "Fixing SteamOS keyring" df_run "$DOTFILES_BIN/dotfiles-steamdeck" fix-keyring || df_fail "Failed SteamOS keyring fix"

# Setup third-party repositories (Chaotic AUR + CachyOS)
run_step "Setting up third-party repositories" df_run "$DOTFILES_BIN/dotfiles-arch" setup-repositories || df_fail "Failed repository setup"

# Install essential packages from standard pacman repos (needed before
# install-yay, which requires git + base-devel). Repos were just refreshed
# above, so -S --needed is enough here.
pacman_install "-S --needed --noconfirm --noprogressbar" \
  nano htop iftop mtr dkms lz4 bash-completion base-devel pacman-contrib \
  git zsh unzip python3 zip vi fakeroot openssh stow sqlite tmux wget entr less

# Rust toolchain (bundles cargo) + exiftool
pacman_install "-S --needed --noconfirm --noprogressbar" rust perl-image-exiftool

# Install xdvdfs-cli via cargo
if command -v cargo >/dev/null 2>&1; then
  run_step "Installing xdvdfs-cli" df_run cargo install xdvdfs-cli || df_warn "xdvdfs-cli install via cargo failed/skipped"
else
  df_warn "cargo not found, skipping xdvdfs-cli install"
fi

# Install AUR helper, then mandatory
run_step "Installing yay" df_run "$DOTFILES_BIN/dotfiles-arch" install-yay || df_fail "Failed yay installation"
run_step "Installing mandatory packages" df_run "$DOTFILES_BIN/dotfiles-arch" install-packages || df_fail "Failed package installation"

# Locking SteamOS rootfs...
run_step "Locking SteamOS rootfs" df_run sudo steamos-readonly enable || df_fail "Failed to enable steamos-readonly"

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  df_ok "Setup Completed."
  df_info "Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
fi

exit 0
