#!/bin/sh

OS=$(uname)

if [ "$OS" == "Linux" ]; then
    cd ~
    cd ./Sync
    nvim
elif [ "$OS" == "Darwin" ]; then
    cd '/Users/c043/Sync'
    nvim
fi
