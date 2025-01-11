#!/bin/zsh

if ! iwgetid -r | grep -q "FASTWEB-RGFPEA"; then
	eval "sudo rfkill unblock 1"
	eval "sudo nmcli c up FASTWEB-RGFPEA"
fi
