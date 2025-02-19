#!/bin/sh
git clone https://github.com/phpenv/phpenv.git ~/.phpenv
export PATH="$HOME/.phpenv/bin:$PATH"
eval "$(phpenv init -)"
git clone https://github.com/php-build/php-build $(phpenv root)/plugins/php-build
# Always the updated version of PHP, due to dependency issue on C compiler.
phpenv install 8.3.13
phpenv rehash
