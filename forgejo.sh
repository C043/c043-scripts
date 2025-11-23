#!/bin/bash

set -e

# Try to get repo name from origin URL
REPO=$(basename -s .git "$(git config --get remote.origin.url 2>/dev/null)")

# Fallback to directory name if Git URL unavailable
if [ -z "$REPO" ]; then
	REPO=$(basename "$(pwd)")
fi

# Ask for confirmation
echo "Detected repository name: $REPO"
read -p "Is this correct? (y/n) " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
	read -p "Enter the correct repository name: " REPO
fi

FORGEJO_URL="http://100.87.246.98:5001"

FJ_USER="c043"

# Your GitHub username (auto-detected if present)
GH_USER=$(git config --get remote.origin.url | sed -E 's#.*github.com[:/]+([^/]+)/.*#\1#')

if [ -z "$GH_USER" ]; then
	read -p "Enter your GitHub username: " GH_USER
fi

echo "Configuring mirrored push for repo: $REPO"
echo "GitHub user:  $GH_USER"
echo "Forgejo user: $FJ_USER"
echo "Forgejo URL:  $FORGEJO_URL"
echo

echo "Checking for existing push URLs..."

EXISTING_PUSHURLS=$(git config --get-all remote.origin.pushurl || true)

if [ -z "$EXISTING_PUSHURLS" ]; then
	echo "No explicit pushurl config for 'origin' — nothing to remove."
else
	echo "Removing existing pushurl entries for 'origin'..."
	echo "$EXISTING_PUSHURLS" | while read -r url; do
		[ -n "$url" ] && git remote set-url --push --delete origin "$url"
	done
fi

# 1. Ensure origin fetch URL remains GitHub
git remote set-url origin "https://github.com/$GH_USER/$REPO.git"

# 2. Clear existing push URLs (for safety)
git remote set-url --push origin "https://github.com/$GH_USER/$REPO.git"

# 3. Add Forgejo as second push target
git remote set-url --push --add origin "$FORGEJO_URL/$FJ_USER/$REPO.git"

echo
echo "Done! 'origin' now pushes to BOTH GitHub and Forgejo."
echo

git remote -v
