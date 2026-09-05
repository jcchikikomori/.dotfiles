#!/bin/sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_BIN="${DOTFILES_BIN:-$SCRIPT_DIR/../linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin}"

if [ ! -r "$DOTFILES_BIN/dotfiles-lib-output" ]; then
  echo "[dotfiles:rhel-setup] Error: dotfiles-lib-output not found" >&2
  exit 1
fi

# shellcheck source=/dev/null
. "$DOTFILES_BIN/dotfiles-lib-output"

DF_PREFIX="rhel-setup"
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

df_info "Installing dependencies from system..."
run_step "Installing development tools" df_run sudo dnf group install -y "development-tools" || df_fail "Failed to install development-tools"
run_step "Installing compiler prerequisites" df_run sudo dnf install -y gcc-c++ make ccache || df_fail "Failed to install compiler prerequisites"
# NOTES:
# - xorg-x11-server-Xvfb = X virtual framebuffer (Camoufox MCP / headless browser automation)
# - podman-compose = compose-compatible wrapper for podman
run_step "Installing base utilities" df_run sudo dnf install -y vim gvim nano htop iftop stow git zsh unzip xclip xsel ncdu wget gawk xorg-x11-server-Xvfb podman-compose || df_fail "Failed to install base utilities"
run_step "Installing perl" df_run sudo dnf install -y perl || df_fail "Failed to install perl"
run_step "Installing php/composer" df_run sudo dnf install -y php composer || df_fail "Failed to install php/composer"
run_step "Installing zenity" df_run sudo dnf install -y zenity || df_fail "Failed to install zenity"

# Installing rclone
run_step "Installing rclone" df_run sudo dnf install -y rclone || df_fail "Failed to install rclone"

# Rust toolchain + cargo + exiftool
run_step "Installing rust/cargo/exiftool" df_run sudo dnf install -y rust cargo perl-Image-ExifTool || df_fail "Failed to install rust/cargo/exiftool"

# Install xdvdfs-cli via cargo
if command -v cargo >/dev/null 2>&1; then
  run_step "Installing xdvdfs-cli" df_run cargo install xdvdfs-cli || df_warn "xdvdfs-cli install via cargo failed/skipped"
else
  df_warn "cargo not found, skipping xdvdfs-cli install"
fi

# Python
run_step "Installing Python runtime/deps" df_run sudo dnf install -y python2 python3 libssh-devel libgcrypt libgcrypt-devel tk-devel tc-devel || df_fail "Failed to install Python runtime/deps"
run_step "Installing Python build deps" df_run sudo dnf install -y bzip2-devel ncurses-devel libffi-devel readline-devel openssl-devel xz-devel libuuid-devel gdbm-libs libnsl2 || df_fail "Failed to install Python build deps"
run_step "Installing Python tooling" df_run sudo dnf install -y python3-tmuxp python3-packaging python3-pip python3-virtualenv || df_fail "Failed to install Python tooling"

# PHP
run_step "Installing PHP build dependencies" df_run sudo dnf install -y \
      bash \
      bison \
      bzip2 \
      bzip2-devel \
      curl \
      diffutils \
      findutils \
      gcc \
      libarchive \
      libcurl-devel \
      libicu-devel \
      libjpeg-turbo-devel \
      libmcrypt-devel \
      libpng-devel \
      libtidy-devel \
      libxml2-devel \
      libxslt-devel \
      openssl-devel \
      patch \
      pkgconf \
      readline-devel \
      sqlite-devel \
      zlib-devel \
      cmake3 || df_fail "Failed to install PHP build dependencies"

if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  df_ok "Setup Completed."
  df_info "Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
fi

exit 0
