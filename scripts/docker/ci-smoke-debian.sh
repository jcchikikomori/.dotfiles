#!/bin/sh
set -eu

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y git make stow ca-certificates curl gnupg

HOME_DIR=${HOME:-/root}
mkdir -p "$HOME_DIR/.dotfiles"

# Mirror CI behavior by running from the canonical dotfiles location.
cp -a /workspace/. "$HOME_DIR/.dotfiles/"
cd "$HOME_DIR/.dotfiles"

mkdir -p "$HOME_DIR/.local/state/dotstow"
ln -snf "$HOME_DIR/.dotfiles" "$HOME_DIR/.local/state/dotstow/dotfiles"

# Ensure dotstow is installed before stow workflows run.
sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-dotstow

# Exercise the same path used in CI workflows in non-interactive mode.
yes y | sh debian/stowme.sh

echo "Debian compose smoke test passed."
