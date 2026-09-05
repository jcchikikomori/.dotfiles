#!/bin/sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_BIN="${DOTFILES_BIN:-$SCRIPT_DIR/../linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin}"

if [ ! -r "$DOTFILES_BIN/dotfiles-lib-output" ]; then
  echo "[dotfiles:darwin-setup] Error: dotfiles-lib-output not found" >&2
  exit 1
fi

# shellcheck source=/dev/null
. "$DOTFILES_BIN/dotfiles-lib-output"

DARWIN_SETUP_VERBOSE=0
for arg in "$@"; do
  case "$arg" in
    --verbose|-v)
      DARWIN_SETUP_VERBOSE=1
      ;;
  esac
done

DF_PREFIX="darwin-setup"
if [ "$DARWIN_SETUP_VERBOSE" -eq 1 ]; then
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
    df_step_end 0
    return 0
  fi
  code=$?
  df_step_end "$code"
  return "$code"
}

df_info "Installing dependencies for macOS..."

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  df_info "Homebrew is not installed. Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if ! command -v brew >/dev/null 2>&1; then
    df_error "Failed to install Homebrew. Exiting..."
    exit 1
  fi
}

ensure_brew

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

run_step "Updating Homebrew" df_run brew update || df_fail "Failed to update Homebrew"
run_step "Installing Homebrew packages" df_run brew install stow git zsh tmux wget coreutils rclone rust exiftool || df_fail "Failed to install Homebrew packages"

# Install xdvdfs-cli via cargo
if command -v cargo >/dev/null 2>&1; then
  run_step "Installing xdvdfs-cli" df_run cargo install xdvdfs-cli || df_warn "xdvdfs-cli install via cargo failed/skipped"
else
  df_warn "cargo not found, skipping xdvdfs-cli install"
fi

if ! xcode-select -p >/dev/null 2>&1; then
  if [ -n "$CI" ]; then
    df_warn "Xcode Command Line Tools are unavailable in CI. Skipping prompt-based installation."
  else
    df_info "Xcode Command Line Tools are required. Running xcode-select --install..."
    xcode-select --install || true
  fi
fi

if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  df_ok "Setup Completed."
  df_info "Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
fi

exit 0
