#!/bin/zsh

img="$1"

cols=$(tput cols)
rows=$(tput lines)

kitty +kitten icat --place="${cols}x${rows}@0x0" "$img"
