#!/bin/bash

type=$1
use=$2
area=$3

time=$(date -u +%Y-%m-%dT%H:%M:%S%Z)

# Make it execute the below commands if the screenshot paramter is passed in $1

if [[ $type == "screenshot" ]]; then

	if [[ $area == "area" ]]; then
		~/.bin/scripts/hyprshot.sh -m region -o "/home/$(whoami)/Documents/Screenshots" -f $time.png
	elif [[ $area == "window" ]]; then
		~/.bin/scripts/hyprshot.sh -m window -m active -o "/home/$(whoami)/Documents/Screenshots" -f $time.png
	elif [[ $area == "output" ]]; then
		~/.bin/scripts/hyprshot.sh -m output -m active -o "/home/$(whoami)/Documents/Screenshots" -f $time.png
	else
		exit 1
	fi

	if [[ -e $file_path ]]; then
		if [[ $2 == "copy" ]]; then
			wl-copy <$file_path
			notify-send "Copied to clipboard"
			exit 0
		elif [[ $2 == "upload" ]]; then
			notify-send "Function was removed, reimplement it you shit head..."
		fi
	else
		echo "Screenshot not taken. Exiting."
		exit 1
	fi
elif [[ $type == "video" ]]; then
	notify-send "Function was removed, reimplement it you shit head..."
fi

exit 0
