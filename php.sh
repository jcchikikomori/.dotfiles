#!/bin/sh

# Store current directory
ORIGINAL_DIR=$(pwd)

# Create a temporary working directory
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

# Change to temporary directory
cd "$WORKDIR"

# Download and extract libzip
curl -L https://github.com/nih-at/libzip/releases/download/v1.7.3/libzip-1.7.3.tar.gz -o libzip-1.7.3.tar.gz && \
tar -zxvf libzip-1.7.3.tar.gz && \
cd libzip-1.7.3 && \
cmake3 . -DCMAKE_INSTALL_PREFIX=/usr && \
make && \
sudo make install

# Install phpenv
git clone https://github.com/phpenv/phpenv.git ~/.phpenv
export PATH="$HOME/.phpenv/bin:$PATH"
eval "$(phpenv init -)"

# Install php-build plugin
git clone https://github.com/php-build/php-build $(phpenv root)/plugins/php-build

# Return to original directory
cd "$ORIGINAL_DIR"

# Clean up temporary directory
rm -rf "$WORKDIR"

# Always the updated version of PHP, due to dependency issue on C compiler.
# phpenv install 8.3.13
phpenv rehash
