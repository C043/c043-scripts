#!/bin/zsh

COUNT=4
while read -r url; do
    curl -o "Episode $COUNT.mp4" $url
    COUNT=$(($COUNT + 1))
done < "urls.txt"
