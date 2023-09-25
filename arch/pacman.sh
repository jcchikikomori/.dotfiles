#!/bin/sh

# Source: https://gist.github.com/bouroo/b750d3fa357362772082407cfa21fb4a
# Fork: https://gist.github.com/jcchikikomori/0984ae8111496ea7544b6452adbbe180

# Init pacman mirror
curl -s -L "https://www.archlinux.org/mirrorlist/?country=TH&country=SG&country=IN&country=JP&protocol=https&ip_version=4" | sed -e 's/^#Server/Server/' -e '/^#/d' > /etc/pacman.d/mirrorlist
# Init key
pacman-key --init
# Init archlinux key
pacman-key --populate archlinux
# Sync repo
yes '' | pacman -Syyu
# Install commom package
yes '' | pacman -S sudo htop iftop mtr dkms lz4 bash-completion base-devel pacman-contrib git
# Sort repo by speed
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
rankmirrors -n 5 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

# Create non root user
useradd admin -m
passwd admin
# Add admin to wheel group
usermod -aG wheel admin
# Allow wheel group sudo
echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
