#!/usr/bin/env bash
TARGET=google.com
IFACE=wlan0             # adjust interface name
CON_NAME="FASTWEB-RGFPEA"    # NetworkManager connection profile

if ! ping -I "$IFACE" -c 2 -W 3 "$TARGET" >/dev/null 2>&1; then
    nmcli dev wifi rescan
    nmcli con down "$CON_NAME" >/dev/null 2>&1
    nmcli con up "$CON_NAME"
fi
