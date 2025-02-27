#!/bin/sh

# Git flow
wget -q https://raw.githubusercontent.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh && sudo bash gitflow-installer.sh install develop
rm -f gitflow-installer.sh
