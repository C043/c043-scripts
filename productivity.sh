#!/bin/zsh

urls=(
    "https://webmail.register.it/appsuite/#!!&app=io.ox/mail&folder=default0/INBOX"
    "https://chat.google.com/app/home"
    "https://trello.com/b/3VlJIXrb/forge"
)

case "$(uname -s)" in
    Darwin*)
        # ---- macOS ----
        open -na "Google Chrome" --args --new-window "${urls[1]}"
        sleep 2
        open -na "Google Chrome" --args "${urls[2]}"
        sleep 2
        open -na "Google Chrome" --args "${urls[3]}"
        ;;
    Linux*)
        # ---- Linux (original commands) ----
        nohup google-chrome --new-window "${urls[1]}" >/dev/null 2>&1 &
        sleep 2
        nohup google-chrome "${urls[2]}" >/dev/null 2>&1 &
        sleep 2
        nohup google-chrome "${urls[3]}" >/dev/null 2>&1 &
        ;;
    *)
        echo "Unsupported platform: $(uname -s)" >&2
        exit 1
        ;;
esac
