#!/bin/zsh

TMPFILE=$(mktemp --suffix=.md)

kitty nvim "$TMPFILE"
cat "$TMPFILE" | xclip -selection clipboard

xdotool key --clearmodifiers ctrl+v

rm "$TMPFILE"
