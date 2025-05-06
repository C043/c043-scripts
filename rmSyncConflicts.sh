#!/bin/zsh

# Removes all sync conflict files from this directory and its subdirectories
sudo find . -type f -name "*sync-conflict*" -exec rm {} \;
