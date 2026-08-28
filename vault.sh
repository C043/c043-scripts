#!/bin/sh

OS=$(uname)

if [ "$OS" == "Linux" ]; then
    cd ~
    cd ./Sync
    nvim
elif [ "$OS" == "Darwin" ]; then
    cd '/Users/ultramaggot/Obsidian Vault'
    nvim
fi
