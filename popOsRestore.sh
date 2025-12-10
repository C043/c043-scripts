#!/bin/bash

set -euo pipefail

echo "Restoring repo/keys APT, fstab and fonts..."
sudo tar xzf etc-backup.tar.gz -C /
sudo apt-get update

if [ -d "$HOME/.local/share/fonts" ]; then
	sudo chown -R "$USER:$USER" "$HOME/.local/share/fonts" && fc-cache -f
fi

echo "Installing APT packages..."
sudo apt-get install $(cat apt-manual.txt) git libgirepository1.0-dev gcc libcairo2-dev pkg-config python3-dev gir1.2-gtk-4.0 pipx
pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"
export HINTS_EXPECTED_BIN_DIR="$HOME/.local/bin"
pipx install git+https://github.com/AlfredoSequeida/hints.git
systemctl --user daemon-reload
systemctl --user enable hintsd
systemctl --user start hintsd

echo "Installing node..."
export NVM_DIR="$HOME/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
# nuova shell oppure risource lo script:
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install node

echo "Installing global node packages..."
if [ -s npm-globals.txt ]; then
	npm install -g $(cat npm-globals.txt)
fi

echo "Installing snap packages..."
xargs -a snap-list.txt -I{} sudo snap install {}

echo "Restoring GNOME settings..."
dconf load /org/gnome/ <gnome-settings.ini

echo "Partial restore done."
echo "Next steps if not done yet:"
echo "- sudo apt-get install system76-driver-nvidia"
echo "- sudo tailscale up"
echo "- Restore the appImages from the list."
echo "- Restore the .desktop from the list."
echo "- Restore GNOME extensions from the list and run this command from this directory:"
echo 'while read -r ext; do gnome-extensions enable "$ext"; done < gnome-extensions.txt'
