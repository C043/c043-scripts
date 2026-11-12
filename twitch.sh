#!/bin/sh
# Usage: twitch.sh <channel>
CHANNEL=$(printf '%s' "$1" | tr -cd 'A-Za-z0-9_')
[ -z "$CHANNEL" ] && { echo "usage: $0 <channel>"; exit 1; }
PORT=8080

/usr/bin/tmux kill-session -t twitch 2>/dev/null

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

/usr/bin/tmux new-session -d -s twitch "/home/c043/.local/bin/streamlink --player-external-http --player-external-http-port $PORT https://www.twitch.tv/$CHANNEL best"
sleep 3
if /usr/bin/tmux has-session -t twitch 2>/dev/null; then
  echo "Started twitch: $CHANNEL"
else
  echo "Failed: streamlink exited (offline channel or port $PORT busy?)"
  exit 1
fi
