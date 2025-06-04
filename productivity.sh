#!/bin/zsh

urls=(
  "https://webmail.register.it/appsuite/#!!&app=io.ox/mail&folder=default0/INBOX"
  "https://mail.google.com/chat/u/1/#chat/space/AAAAvvo6XTk"
  "https://trello.com/b/fGWIkmKH/stocktitan"
)

case "$(uname -s)" in
  Darwin*)
    # ---- macOS ----
    open -na "Vivaldi" --args --new-window "${urls[1]}"
    sleep 2
    open -na  "Vivaldi" --args "${urls[2]}"
  sleep 2
    open -na  "Vivaldi" --args "${urls[3]}"
    ;;
  Linux*)
    # ---- Linux (original commands) ----
    nohup vivaldi.vivaldi-stable --new-window "${urls[1]}" > /dev/null 2>&1 &
    sleep 2
    nohup vivaldi.vivaldi-stable "${urls[2]}" > /dev/null 2>&1 &
    sleep 2
    nohup vivaldi.vivaldi-stable "${urls[3]}" > /dev/null 2>&1 &
    ;;
  *)
    echo "Unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac
