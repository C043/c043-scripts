#!/bin/bash
set -e

cd /home/c043/GitHub/coding-blog
git switch develop
if ! git diff-index --quiet HEAD --; then
	echo "You have uncommitted changes on develop. Exiting."
	exit 1
fi
git pull

git switch master
if ! git diff-index --quiet HEAD --; then
	echo "You have uncommitted changes on master. Exiting."
	exit 1
fi
git merge --ff-only develop
git push origin master
