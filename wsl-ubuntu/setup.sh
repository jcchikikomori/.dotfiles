#!/bin/sh

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo apt-get install -y git zsh

# New method on setting up systemctl
# Source: https://github.com/nullpo-head/wsl-distrod
curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
chmod +x install.sh
sudo ./install.sh install

# If you want to automatically start your distro on Windows startup, enable distrod by the following command
#/opt/distrod/bin/distrod enable --start-on-windows-boot
# Otherwise
/opt/distrod/bin/distrod enable

curl -sS https://starship.rs/install.sh | sh
curl -L git.io/antigen >$HOME/antigen.zsh

# always put this oh-my-zsh into the end
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
