#!/bin/zsh

TMPFILE=$(mktemp)

kitty nvim "$TMPFILE"
cat "$TMPFILE" | xclip -selection clipboard

xdotool key --clearmodifiers ctrl+v

rm "$TMPFILE"
