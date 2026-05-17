#!/bin/sh

TMPFILE=$(mktemp --suffix=.md)
trap 'rm -f "$TMPFILE"' EXIT

kitty nvim "$TMPFILE"

if command -v wl-copy >/dev/null 2>&1 && [ -n "${WAYLAND_DISPLAY:-}" ]; then
  wl-copy < "$TMPFILE"
elif command -v xclip >/dev/null 2>&1; then
  xclip -selection clipboard < "$TMPFILE"
else
  printf '%s\n' "No clipboard tool found. Install wl-clipboard on Wayland or xclip on X11." >&2
  exit 1
fi
