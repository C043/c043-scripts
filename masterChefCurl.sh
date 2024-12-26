#!/bin/zsh

COUNT=6
while read -r url; do
    NAME="Episode $COUNT.mp4"
    echo "Downloading $NAME"
    curl -o "Episode $COUNT.mp4" $url
    COUNT=$(($COUNT + 1))
done < "/home/c043/c043-scripts/urls.txt"
