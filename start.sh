#!/bin/sh

mkdir -p $HOME/bin
rm -rf $HOME/bin/*
cp -rf ./linux/systems/bin/* $HOME/bin/

echo "Welcome! You may proceed to your chosen systems then execute setup.sh"
