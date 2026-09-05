#!/bin/sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_BIN="${DOTFILES_BIN:-$SCRIPT_DIR/../linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin}"

if [ ! -r "$DOTFILES_BIN/dotfiles-lib-output" ]; then
  echo "[dotfiles:arch-setup] Error: dotfiles-lib-output not found" >&2
  exit 1
fi

# shellcheck source=/dev/null
. "$DOTFILES_BIN/dotfiles-lib-output"

ARCH_SETUP_VERBOSE=0
for arg in "$@"; do
  case "$arg" in
    --verbose|-v)
      ARCH_SETUP_VERBOSE=1
      ;;
  esac
done

DF_PREFIX="arch-setup"
if [ "$ARCH_SETUP_VERBOSE" -eq 1 ]; then
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

# Setting default locale
run_step "Setting keyboard + locale" df_run sudo sh -c "loadkeys us && sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' /etc/locale.gen && locale-gen en_US.UTF-8 && localectl set-locale LANG=en_US.UTF-8" || df_fail "Failed locale setup"

# Install essentials
pacman_install "-Syyu --noconfirm --noprogressbar" nano htop iftop mtr dkms lz4 bash-completion base-devel pacman-contrib git zsh unzip
pacman_install "-S --noconfirm --noprogressbar" base-devel python3 zip unzip vi nano fakeroot openssh stow sqlite tmux wget entr less

# AUR repository setup, yay installation, and AUR packages are now handled by
# the dotfiles-arch utility. Run `dotfiles-arch setup` after this script.

# Compilation Cache
pacman_install "-S --noconfirm --noprogressbar" ccache

# Workarounds & Misc software
pacman_install "-S --noconfirm --noprogressbar" xclip
# Install mirror management tools
pacman_install "-S --noconfirm --noprogressbar" rankmirrors reflector

# Rust toolchain (bundles cargo) + exiftool
pacman_install "-S --noconfirm --noprogressbar" rust perl-image-exiftool

# Install xdvdfs-cli via cargo
if command -v cargo >/dev/null 2>&1; then
  run_step "Installing xdvdfs-cli" df_run cargo install xdvdfs-cli || df_warn "xdvdfs-cli install via cargo failed/skipped"
else
  df_warn "cargo not found, skipping xdvdfs-cli install"
fi

# Post-Setup
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  df_ok "Setup Completed."
  df_info "Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
fi

exit 0
