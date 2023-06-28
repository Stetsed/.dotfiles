#!/bin/bash

if [[ -f .packages.list ]]; then
	# My Repository uses Chroot Build in Paru so need to add below to pacman.conf
	echo -e "[options]\nCacheDir = /var/lib/repo/aur\n\n[aur]\nSigLevel = PackageOptional DatabaseOptional\nServer = file:///var/lib/repo/aur" | sudo tee -a /etc/pacman.conf
	# Get the package list from the .packages.list file and install them
	mapfile -t names <.packages.list
	paru -Syu ${names[@]}
else
	echo "No .packages.list file found. Skipping package installation."
fi
