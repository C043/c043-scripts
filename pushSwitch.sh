#!/bin/bash

if ! git push; then
	gh auth switch
	git push
fi
