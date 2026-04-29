#!/bin/sh

TMPFILE=$(mktemp --suffix=.md)

kitty vim "$TMPFILE"
cat "$TMPFILE" | xclip -selection clipboard

rm "$TMPFILE"
