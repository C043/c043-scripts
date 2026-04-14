#!/bin/sh

TMPFILE=$(mktemp --suffix=.md)

kitty vim "$TMPFILE"
cat "$TMPFILE" | xclip -selection clipboard

xdotool key --clearmodifiers ctrl+v

rm "$TMPFILE"
