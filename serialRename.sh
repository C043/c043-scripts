#!/bin/zsh

echo "Type the name"
read name

echo "Type the extension"
read extention

COUNT=1
for i in *; do
    mv "$i" "$name$COUNT.$extention"
    COUNT=$(($COUNT + 1))
done
