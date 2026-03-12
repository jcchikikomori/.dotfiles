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

# Simulate GHCup CI runner behavior: ~/.ghcup is an absolute symlink -> /usr/local/.ghcup.
# This causes "BUG in find_stowed_path" in stow when not excluded. We verify stowme.sh
# handles it correctly by removing and restoring the symlink transparently.
mkdir -p /usr/local/.ghcup
ln -snf /usr/local/.ghcup "$HOME_DIR/.ghcup"
echo "Simulated ~/.ghcup -> /usr/local/.ghcup symlink created."

# Exercise the same path used in CI workflows in non-interactive mode.
yes y | sh debian/stowme.sh

# Verify the symlink was correctly restored after stowing.
if [ -L "$HOME_DIR/.ghcup" ] && [ "$(readlink "$HOME_DIR/.ghcup")" = "/usr/local/.ghcup" ]; then
  echo "~/.ghcup symlink correctly restored after stowing."
else
  echo "ERROR: ~/.ghcup symlink was not restored after stowing!" >&2
  exit 1
fi

echo "Debian compose smoke test passed."
