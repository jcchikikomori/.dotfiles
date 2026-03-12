#!/bin/sh

echo "Installing dependencies for macOS..."

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  echo "Homebrew is not installed. Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if ! command -v brew >/dev/null 2>&1; then
    echo "Failed to install Homebrew. Exiting..." >&2
    exit 1
  fi
}

ensure_brew

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

brew update
brew install stow git zsh tmux wget coreutils

if ! xcode-select -p >/dev/null 2>&1; then
  if [ -n "$CI" ]; then
    echo "Xcode Command Line Tools are unavailable in CI. Skipping prompt-based installation."
  else
    echo "Xcode Command Line Tools are required. Running xcode-select --install..."
    xcode-select --install || true
  fi
fi

if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  echo "Setup Completed."
  echo "Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
fi

exit 0
