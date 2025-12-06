#!/bin/bash

OS=$(uname)

if [ "$OS" == "Linux" ]; then
	cd ~
	cd ./Sync
	nvim ./To-Do.md
elif [ "$OS" == "Darwin" ]; then
	cd '/Users/ultramaggot/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/'
	nvim ./To-Do.md
fi
