#!/bin/sh
# THIS SCRIPT IS FOR ROOT USER ONLY. DO NOT EXECUTE THE SCRIPT AS NON-ROOT USER!

# Source: https://gist.github.com/bouroo/b750d3fa357362772082407cfa21fb4a
# Fork: https://gist.github.com/jcchikikomori/0984ae8111496ea7544b6452adbbe180

# Backup mirrorlist
cp -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
# Install essential packages
pacman -Syy --noconfirm --noprogressbar sudo gvim nano htop iftop mtr dkms lz4 bash-completion base-devel pacman-contrib git zsh unzip
# Init pacman mirror
curl -s -L "https://archlinux.org/mirrorlist/?country=CN&country=JP&country=SG&country=KR&protocol=https&ip_version=4&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' > /etc/pacman.d/mirrorlist
# Init key
pacman-key --init
# Init archlinux key
pacman-key --populate archlinux
# Sync repo
pacman -Syyu --noconfirm --noprogressbar
# Sort repo by speed (pacman-contrib package required)
rankmirrors -n 5 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
