#!/bin/bash

if [[ -f .packages.list ]]; then
	# Get the package list from the .packages.list file and install them
	mapfile -t names <.packages.list
	for package in ${names[@]}; do
		# Make sure it's not a comment line to allow for comments in the list
		if ! [[ $package = *"#"* || $package = "" ]]; then
			packages_to_install+=("$package")
		fi
	done
	yay -Syu ${packages_to_install[@]}

else
	echo "No .packages.list file found. Skipping package installation."
fi
