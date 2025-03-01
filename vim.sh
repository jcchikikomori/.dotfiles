#!/bin/bash

# Set timeout (in seconds)
TIMEOUT=300

# Create lock file to prevent concurrent installations
LOCK_FILE="/tmp/vim-plugin-install.lock"

# Store original directory
ORIGINAL_DIR=$(pwd)

# Create temporary working directory
WORKDIR=$HOME

# Change to temporary directory
cd "$WORKDIR"

# Dependency
echo "Installing vim-plug plugin manager"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Ensure .vimrc is loaded
cp -f linux/vim/.vimrc ~/.vimrc

# Acquire lock
(
    flock -n 200 || { 
        echo "Error: Another plugin installation is in progress"
        exit 1
    }

    # Install plugins with verbose logging
    echo "Starting plugin installation..."
    timeout $TIMEOUT vim +"set verbosefile=/tmp/vim-verbose.log" \
        +"silent! PlugUpdate --sync" \
        +"redir >> /tmp/vim-verbose.log | silent! PlugStatus | redir END" \
        +qa!

    STATUS=$?

    # Check installation status
    if [ $STATUS -eq 124 ]; then
        echo "Error: Installation timed out!"
    elif [ $STATUS -ne 0 ]; then
        echo "Error: Plugin installation failed!"
    else
        echo "Plugins installed successfully"
    fi

) 200>$LOCK_FILE

# Return to original directory
cd "$ORIGINAL_DIR"
