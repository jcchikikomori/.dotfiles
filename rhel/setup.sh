#!/bin/sh

echo 'Installing dependencies from system...'
sudo dnf group install -y "development-tools"
sudo dnf install -y gcc-c++ make ccache
sudo dnf install -y vim gvim nano htop iftop stow git zsh unzip xsel ncdu wget gawk
sudo dnf install -y perl
sudo dnf install -y php composer
sudo dnf install -y zenity

# Python
sudo dnf install -y python2 python3 libssh-devel libgcrypt libgcrypt-devel tk-devel tc-devel
sudo dnf install -y python3-tmuxp python3-packaging python3-pip python3-virtualenv

# PHP
sudo dnf install -y \
      bash \
      bison \
      bzip2 \
      bzip2-devel \
      curl \
      diffutils \
      findutils \
      gcc \
      libarchive \
      libcurl-devel \
      libicu-devel \
      libjpeg-turbo-devel \
      libmcrypt-devel \
      libpng-devel \
      libtidy-devel \
      libxml2-devel \
      libxslt-devel \
      openssl-devel \
      patch \
      pkgconf \
      readline-devel \
      sqlite-devel \
      zlib-devel \
      cmake3

if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Setup Completed" --text="Please install dependencies into your home directory (Execute: dotfiles-post-setup)."
else
  echo "Setup Completed."
  echo 'Please install dependencies into your home directory (Execute: dotfiles-post-setup).'
fi

exit 0
