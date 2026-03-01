#!/bin/sh
# =============================================================================
# Gitmux Installation Script
# =============================================================================
# Installs gitmux - a git status display for tmux
# Reference: https://github.com/arl/gitmux

set -e

GITMUX_REPO="https://github.com/arl/gitmux.git"
INSTALL_DIR="${HOME}/.local/bin/org.jcchikikomori.dotfiles/bin"

echo "Installing gitmux..."

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Check if gitmux is already installed
if command -v gitmux >/dev/null 2>&1; then
    echo "✓ gitmux is already installed"
    gitmux --version
    exit 0
fi

# Try to install via package manager first
if command -v brew >/dev/null 2>&1; then
    echo "Installing via Homebrew..."
    brew install gitmux
elif command -v apt-get >/dev/null 2>&1; then
    echo "Installing via apt..."
    sudo apt-get update
    sudo apt-get install -y gitmux
elif command -v dnf >/dev/null 2>&1; then
    echo "Installing via dnf..."
    sudo dnf install -y gitmux
elif command -v pacman >/dev/null 2>&1; then
    echo "Installing via pacman..."
    sudo pacman -S --noconfirm gitmux
elif command -v pkg >/dev/null 2>&1; then
    echo "Installing via pkg (Termux)..."
    pkg install -y gitmux
else
    echo "Error: No supported package manager found"
    echo "Supported: brew, apt, dnf, pacman, pkg"
    exit 1
fi

if command -v gitmux >/dev/null 2>&1; then
    echo "✓ gitmux installed successfully"
    gitmux --version
else
    echo "✗ Installation failed"
    exit 1
fi
