#!/bin/sh

# Installing a dependency
curl -L https://github.com/nih-at/libzip/releases/download/v1.7.3/libzip-1.7.3.tar.gz -o libzip-1.7.3.tar.gz && \
tar -zxvf libzip-1.7.3.tar.gz && \
cd libzip-1.7.3 && \
cmake3 . -DCMAKE_INSTALL_PREFIX=/usr && \
make && \
sudo make install

git clone https://github.com/phpenv/phpenv.git ~/.phpenv
export PATH="$HOME/.phpenv/bin:$PATH"
eval "$(phpenv init -)"
git clone https://github.com/php-build/php-build $(phpenv root)/plugins/php-build
# Always the updated version of PHP, due to dependency issue on C compiler.
# phpenv install 8.3.13
phpenv rehash
