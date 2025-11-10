#!/bin/bash
read -p "Da quale puntata iniziamo? " COUNT
echo "Perfetto, iniziamo dalla puntata $COUNT!"

while read -r url; do
    NAME="Episode $COUNT.mp4"
    echo "Downloading $NAME"

    # Escape square brackets in the URL
    url=${url//[\[\]]/\\&}
    
    curl -o "$NAME" "$url"
    COUNT=$(($COUNT + 1))
done < "/home/c043/GitHub/c043-scripts/masterChefCurl/urls.txt"
