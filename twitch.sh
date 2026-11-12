#!/bin/sh
# Usage: twitch.sh <channel>
# Restarts the "twitch" tmux session with streamlink serving <channel> over HTTP
# on $PORT. The session stops on its own once the channel goes offline.

STREAMLINK=/home/c043/.local/bin/streamlink
TMUX_BIN=/usr/bin/tmux
PORT=8080
CHECK_INTERVAL=180   # seconds between "is it still live?" checks
MAX_FAILS=2          # consecutive failed checks before stopping

is_live() {
  "$STREAMLINK" --json "https://www.twitch.tv/$1" >/dev/null 2>&1
}

# Internal mode: runs inside the tmux session, streams and watches the channel.
if [ "$1" = "--run" ]; then
  CHANNEL=$2
  "$STREAMLINK" --player-external-http --player-external-http-port "$PORT" \
    "https://www.twitch.tv/$CHANNEL" best &
  SL_PID=$!
  trap 'kill $SL_PID 2>/dev/null; exit' INT TERM HUP
  FAILS=0
  while kill -0 "$SL_PID" 2>/dev/null; do
    sleep "$CHECK_INTERVAL"
    if is_live "$CHANNEL"; then
      FAILS=0
    else
      FAILS=$((FAILS + 1))
      echo "[$(date '+%H:%M')] $CHANNEL looks offline ($FAILS/$MAX_FAILS)"
      if [ "$FAILS" -ge "$MAX_FAILS" ]; then
        echo "Stream ended, stopping."
        kill "$SL_PID" 2>/dev/null
        break
      fi
    fi
  done
  wait "$SL_PID" 2>/dev/null
  exit 0
fi

CHANNEL=$(printf '%s' "$1" | tr -cd 'A-Za-z0-9_')
[ -z "$CHANNEL" ] && { echo "usage: $0 <channel>"; exit 1; }

# Check before touching the current stream, so an offline channel changes nothing
if ! is_live "$CHANNEL"; then
  echo "Failed: $CHANNEL is offline (or doesn't exist)"
  exit 1
fi

$TMUX_BIN kill-session -t twitch 2>/dev/null

# Free the port: stop whatever of ours is still listening on it
PIDS=$(ss -Htlnp "sport = :$PORT" 2>/dev/null | grep -o 'pid=[0-9]*' | cut -d= -f2 | sort -u)
if [ -n "$PIDS" ]; then
  kill $PIDS 2>/dev/null
  for i in 1 2 3 4 5 6 7 8 9 10; do
    ss -Htln "sport = :$PORT" | grep -q . || break
    sleep 0.5
  done
  kill -9 $PIDS 2>/dev/null
fi

SELF=$(readlink -f "$0")
$TMUX_BIN new-session -d -s twitch "$SELF --run $CHANNEL"
sleep 3
if $TMUX_BIN has-session -t twitch 2>/dev/null; then
  echo "Started twitch: $CHANNEL"
else
  echo "Failed: streamlink exited (port $PORT busy?)"
  exit 1
fi
