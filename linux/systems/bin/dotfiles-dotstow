#!/bin/bash

WORKDIR="$HOME"
ORIGINAL_DIR=$(pwd)

# Function to check if a command is installed
check_command() {
    if ! which "$1" >/dev/null 2>&1; then
        echo "ERROR: $1 is not installed on this system!"
        exit 1
    fi
}

# Prelim checks
check_command make
check_command stow
check_command git

# Clone dotstow repository and install
git clone https://github.com/jcchikikomori/dotstow $WORKDIR/.dotstow
cd $WORKDIR/.dotstow
git checkout b013bfefec0b52254e8faaa77427ae31ef04dcfa
sudo make install

# Return back to original/previous directory
cd $ORIGINAL_DIR
