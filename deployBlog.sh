#!/bin/sh
set -e

# Telegram credentials and posts dir live in .env next to this script
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
if [ -f "$SCRIPT_DIR/.env" ]; then
    . "$SCRIPT_DIR/.env"
fi
POSTS_DIR=${BLOG_POSTS_DIR:-content/posts}

notify_telegram() {
    if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
        echo "Telegram credentials not set, skipping notification."
        return 0
    fi
    curl -fsS -o /dev/null \
        "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        --data-urlencode "chat_id=$TELEGRAM_CHAT_ID" \
        --data-urlencode "text=$1" \
        || echo "Failed to send Telegram notification."
}

cd /home/c043/GitHub/coding-blog
git switch develop
if ! git diff-index --quiet HEAD --; then
    echo "You have uncommitted changes on develop. Exiting."
    exit 1
fi
git pull

git switch master
if ! git diff-index --quiet HEAD --; then
    echo "You have uncommitted changes on master. Exiting."
    exit 1
fi
OLD_HEAD=$(git rev-parse HEAD)
git merge --ff-only develop
git push origin master

# Only files added (not modified) under the posts dir count as new posts
NEW_POSTS=$(git diff --name-only --diff-filter=A "$OLD_HEAD" HEAD -- "$POSTS_DIR")
if [ -n "$NEW_POSTS" ]; then
    notify_telegram "$(printf 'New blog post published:\n%s' "$NEW_POSTS")"
fi
