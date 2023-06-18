#!/bin/bash

cd ~/

if [[ -f .packages.list ]]; then
	mapfile -t names <.packages.list
	paru -Syu ${names[@]}
else
	echo "No .packages.list file found. Skipping package installation."
fi
