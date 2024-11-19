#!/bin/zsh

sudo pacman -Sc
sudo pacman -Qdtq | sudo pacman -Rs -
sudo rm -rf /tmp/*
