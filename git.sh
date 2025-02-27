#!/bin/sh

# Git flow
if command -v wget > /dev/null 2>&1; then
  wget -q https://raw.githubusercontent.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh && sudo bash gitflow-installer.sh install develop
else
  curl --silent --location https://raw.githubusercontent.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh --output ./gitflow-installer.sh install develop
fi
rm -f gitflow-installer.sh
