#!/bin/sh
# THIS SCRIPT IS FOR ROOT USER ONLY. DO NOT EXECUTE THE SCRIPT AS NON-ROOT USER!

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
apt-get install -y sudo vim nano htop iftop mtr dkms lz4 git zsh build-essential sqlite3 ccache tmux unzip
