#!/bin/bash

set -euo pipefail

stamp=$(date +%Y-%m)
dir_name="${stamp}-pop"
mkdir -p "./${dir_name}"
cd "./${dir_name}"

echo "Backing up packages list from apt..."
apt-mark showmanual >apt-manual.txt

echo "Backing up packages list from snap..."
snap list --all | awk 'NR>1 {print $1}' | sort -u >snap-list.txt

echo "Backing up GNOME settings..."
dconf dump /org/gnome/ >gnome-settings.ini

echo "Backing up GNOME active extensions..."
gnome-extensions list --enabled >gnome-extensions.txt

echo "Backing up local appImages..."
ls /usr/local/bin/ >appImages.txt
ls "$HOME/.local/share/applications/" >desktopFiles.txt

echo "Backing up system settings from /etc and local fonts..."
sudo tar --warning=none -czf etc-backup.tar.gz \
	-C / etc/fstab etc/apt/sources.list.d etc/apt/trusted.gpg.d \
	-C "$HOME" .local/share/fonts/
sudo chown "$USER:$USER" etc-backup.tar.gz

echo "Backup done."
