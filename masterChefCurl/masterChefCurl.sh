#!/bin/zsh

COUNT=1
while read -r url; do
    NAME="Episode $COUNT.mp4"
    echo "Downloading $NAME"

    # Escape square brackets in the URL
    url=${url//[\[\]]/\\&}
    
    curl -o "$NAME" "$url"
    COUNT=$(($COUNT + 1))
done < "/home/c043/GitHub/c043-scripts/masterChefCurl/urls.txt"
