#!/bin/zsh

TEXT=$(xclip -selection clipboard -o)

edge-tts --text "$TEXT" --rate +50% --write-media /dev/stdout | mpv --no-terminal -
