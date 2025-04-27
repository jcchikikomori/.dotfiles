#!/bin/sh

if [ -d "$HOME/.pyenv" ]; then
  rm -rf "$HOME/.pyenv"
fi

curl https://pyenv.run | bash

if command -v ccache > /dev/null 2>&1; then
  export CC="ccache gcc"
  export CXX="ccache g++"
  export KERNEL_CC="ccache gcc"
  export UTILS_CC="ccache gcc"
  export UTILS_CXX="ccache g++"
fi

export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"

  pyenv install 3.11.4 -v
  pyenv global 3.11.4
  pyenv rehash
fi
