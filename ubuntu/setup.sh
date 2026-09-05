#!/bin/sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_BIN="${DOTFILES_BIN:-$SCRIPT_DIR/../linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin}"

if [ ! -r "$DOTFILES_BIN/dotfiles-lib-output" ]; then
  echo "[dotfiles:ubuntu-setup] Error: dotfiles-lib-output not found" >&2
  exit 1
fi

# shellcheck source=/dev/null
. "$DOTFILES_BIN/dotfiles-lib-output"

UBUNTU_SETUP_VERBOSE=0
for arg in "$@"; do
  case "$arg" in
    --verbose|-v)
      UBUNTU_SETUP_VERBOSE=1
      ;;
  esac
done

DF_PREFIX="ubuntu-setup"
if [ "$UBUNTU_SETUP_VERBOSE" -eq 1 ]; then
  df_output_init --verbose
  export DOTFILES_VERBOSE=1
else
  df_output_init
fi

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

# Init setup
run_step "Updating apt index" df_run sudo apt-get update || df_fail "Failed apt-get update"
run_step "Installing apt transport dependencies" df_run sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common || df_fail "Failed apt transport dependencies install"

# Install kbd for loadkeys (console keyboard layout)
# Install gnupg for gpgconf and gpg-connect-agent commands
# Install locales for locale-gen
run_step "Installing core packages" df_run sudo apt-get install -y stow vim nano htop iftop mtr dkms lz4 git zsh build-essential sqlite3 ccache tmux unzip kbd gnupg locales || df_fail "Failed core package install"

# Installing essentials (additional)
# NOTES:
# - vim-gtk3 = gvim
# - xvfb = X virtual framebuffer (Camoufox MCP / headless browser automation)
# - podman-compose = compose-compatible wrapper for podman
# TODO(#267): one of these packages is unavailable on the Ubuntu CI image.
# Tolerated for now; the failure is still printed with its log path.
run_step "Installing additional essentials" df_run_soft sudo apt-get install -y python3 zip vi openssh xclip xsel ncdu wget vim-gtk3 xvfb podman-compose || df_warn "additional essential package install failed/skipped (see #267)"

# Installing additional packages (for building others such as pyenv)
run_step "Installing build dependencies" df_run sudo apt-get install -y libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev || df_fail "Failed build dependency install"

# Installing rclone
run_step "Installing rclone" df_run sudo apt-get install -y rclone || df_fail "Failed rclone install"

# Rust toolchain via rustup (apt's rustc/cargo on Ubuntu is too old to build
# current crates - xdvdfs-cli requires Rust edition 2024, rustc >= 1.85) + exiftool
run_step "Installing rust/exiftool prerequisites" df_run sudo apt-get install -y libimage-exiftool-perl || df_fail "Failed exiftool prerequisite install"
if ! command -v cargo >/dev/null 2>&1; then
  run_step "Installing rustup" sh -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable" || df_fail "Failed rustup install"
fi
export PATH="$HOME/.cargo/bin:$PATH"

# Install xdvdfs-cli via cargo
if command -v cargo >/dev/null 2>&1; then
  run_step "Installing xdvdfs-cli" df_run cargo install xdvdfs-cli || df_warn "xdvdfs-cli install via cargo failed/skipped"
else
  df_warn "cargo not found, skipping xdvdfs-cli install"
fi

# Setting default locale (skip loadkeys on WSL as it doesn't support console keymaps)
if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
  df_info "WSL detected: Skipping loadkeys (not supported in WSL)."
else
  if command -v loadkeys >/dev/null 2>&1; then
    df_run sudo loadkeys us || df_warn "loadkeys failed, continuing"
  fi
fi

run_step "Configuring locale" df_run sudo sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' /etc/locale.gen || df_fail "Failed locale.gen update"
df_run sudo locale-gen en_US.UTF-8 || df_fail "Failed locale generation"

# localectl may not work in containers or WSL, handle gracefully
if command -v localectl >/dev/null 2>&1; then
  df_run sudo localectl set-locale LANG=en_US.UTF-8 2>/dev/null || df_warn "localectl set-locale failed (may not work in containers/WSL)"
fi

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  df_ok "Setup Completed."
  df_info "Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
fi

df_ok "Script execution completed."
