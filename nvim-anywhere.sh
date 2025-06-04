#!/bin/zsh

TMPFILE=$(mktemp)

xclip -selection clipboard -o > "$TMPFILE"

kitty nvim "$TMPFILE"
cat "$TMPFILE" | xclip -selection clipboard

xdotool key --clearmodifiers ctrl+v

rm "$TMPFILE"
