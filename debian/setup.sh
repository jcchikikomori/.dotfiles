#!/bin/sh

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo apt-get install -y git zsh

# New method on setting up systemctl
# Source: https://github.com/nullpo-head/wsl-distrod
if [ -n "$WSL_DISTRO_NAME" ]; then
    curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
    chmod +x install.sh
    sudo ./install.sh install

    # If you want to automatically start your distro on Windows startup, enable distrod by the following command
    #/opt/distrod/bin/distrod enable --start-on-windows-boot
    # Otherwise
    /opt/distrod/bin/distrod enable
fi
