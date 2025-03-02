#!/bin/bash

# Exit on any error
set -e

# Suppress progress bars and interactive prompts
export DEBIAN_FRONTEND=noninteractive
export RBENV_ROOT="${HOME}/.rbenv"

# Install rbenv
echo "Installing rbenv..."
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# Verify rbenv installation
echo "Verifying rbenv installation..."
type rbenv

# Install ruby-build plugin
echo "Installing ruby-build plugin..."
mkdir -p "${RBENV_ROOT}/plugins"
git clone --quiet https://github.com/rbenv/ruby-build.git "${RBENV_ROOT}/plugins/ruby-build"

# List available Ruby versions
rbenv install -l > /dev/null

# Install Ruby 2.5.1
echo "Installing Ruby 2.5.1..."
rbenv install --verbose 2.5.1

# Set global Ruby version
echo "Setting Ruby 2.5.1 as global version..."
rbenv global 2.5.1

# Rehash to update shims
echo "Updating shims..."
rbenv rehash

# Verify installation
echo "Installation complete!"
