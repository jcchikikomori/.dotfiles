#!/bin/sh

# Store original directory
ORIGINAL_DIR=$(pwd)

# Create temporary working directory
WORKDIR=$HOME

# Change to temporary directory
cd "$WORKDIR"

# Download installer based on available tool
# Then install
if command -v wget > /dev/null 2>&1; then
  wget -q https://raw.githubusercontent.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh && sudo bash gitflow-installer.sh install develop
else
  curl --silent --location https://raw.githubusercontent.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh --output ./gitflow-installer.sh install develop
fi

# Clean up installer
rm -f gitflow-installer.sh

# Return to original directory
cd "$ORIGINAL_DIR"
