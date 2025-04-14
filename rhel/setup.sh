#!/bin/sh

echo 'Installing dependencies from system...'
sudo dnf group install -y "development-tools"
sudo dnf install -y gcc-c++ make ccache
sudo dnf install -y vim gvim nano htop iftop stow git zsh unzip xsel ncdu wget
sudo dnf install -y python2 python3 libssh-devel libgcrypt libgcrypt-devel
sudo dnf install -y python3-tmuxp
sudo dnf install -y perl
sudo dnf install -y php composer

# PHP dependencies
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
  zenity --info --title="Setup Completed" --text="Please execute post-setup.sh to complete the setup."
else
  echo "Setup Completed. Please execute post-setup.sh to complete the setup."
fi

echo 'Script execution completed.'
