#!/bin/sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_BIN="${DOTFILES_BIN:-$SCRIPT_DIR/../linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin}"

if [ ! -r "$DOTFILES_BIN/dotfiles-lib-output" ]; then
  echo "[dotfiles:termux-setup] Error: dotfiles-lib-output not found" >&2
  exit 1
fi

# shellcheck source=/dev/null
. "$DOTFILES_BIN/dotfiles-lib-output"

DF_PREFIX="termux-setup"
df_output_init

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

# Init setup
# Note: dkms, lz4, sqlite3, ccache are not available in Termux
# Note: vim-gtk3 (gvim) is not available in Termux
# Note: Additional build dependencies may not be available in Termux
# Change mirrors first based on your location
# Note: Execute `export TERM=xterm-256color` if you face any terminal issues
export TERM=xterm-256color
run_step "Changing Termux repository mirror" df_run termux-change-repo || df_fail "Failed to change Termux repository mirror"
run_step "Updating Termux package index" df_run pkg update || df_fail "Failed pkg update"

run_step "Installing base packages" df_run pkg install -y apt ca-certificates curl || df_fail "Failed base package install"
run_step "Installing shell/dev packages" df_run pkg install -y stow vim nano htop git zsh build-essential which || df_fail "Failed shell/dev package install"
run_step "Installing utility packages" df_run pkg install -y python zip openssh ncdu wget tmux unzip rclone || df_fail "Failed utility package install"
run_step "Installing rust/exiftool" df_run pkg install -y rust exiftool || df_fail "Failed rust/exiftool install"

# Install xdvdfs-cli via cargo
if command -v cargo >/dev/null 2>&1; then
  run_step "Installing xdvdfs-cli" df_run cargo install xdvdfs-cli || df_warn "xdvdfs-cli install via cargo failed/skipped"
else
  df_warn "cargo not found, skipping xdvdfs-cli install"
fi

# Setting default locale
# Termux does not use loadkeys or localectl, locale settings are managed differently
# Workaround: termux-reload-settings may fail with app_process errors in some environments
termux-reload-settings 2>/dev/null || df_warn "termux-reload-settings not available, skipping"
df_run sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' "$PREFIX/etc/locale.gen" || df_fail "Failed locale.gen update"
df_run locale-gen en_US.UTF-8 || df_fail "Failed locale generation"
export LANG=en_US.UTF-8

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  df_ok "Setup Completed."
  df_info "Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
fi

df_ok "Script execution completed."
