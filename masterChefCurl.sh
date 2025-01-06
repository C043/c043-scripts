#!/bin/zsh

COUNT=1
while read -r url; do
    NAME="Episode $COUNT.mp4"
    echo "Downloading $NAME"
    curl -o $NAME $url
    COUNT=$(($COUNT + 1))
done < "/home/c043/c043-scripts/urls.txt"
