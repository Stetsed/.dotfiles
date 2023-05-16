#!/bin/bash

# HOW TO USE
# 1. Create a collection named "images" in PocketBase
# 2. Copy the API key from PocketBase Local Storage
# 3. Create a file named ".env" in your home directory
# 4. Paste the API key in the .env file with the following format: AUTHORIZATION="(API key)"
# 5. Make the file executable with the following command: chmod +x screenshot.sh
# 6. Update the URL's to match your pocketbase instance. So you want to replace pocketbase.selfhostable.net

mode=$1

if [ -z "$mode" ]; then
	echo "Mode is empty. Exiting."
	exit 1
fi

set -a
source ~/.env
set +a

time=$(date -u +%Y-%m-%dT%H:%M:%S%Z)

file_path=~/Documents/Screenshots/$time.png

grimblast --notify save $mode $file_path

if [[ -e $file_path ]]; then
	json=$(curl -X POST -H "Authorization: $AUTHORIZATION" https://pocketbase.selfhostable.net/api/collections/images/records --form "file=@\"$file_path\"")

	collectionName=$(echo "$json" | jq -r '.collectionName')
	id=$(echo "$json" | jq -r '.id')
	file=$(echo "$json" | jq -r '.file')

	image_link="https://pocketbase.selfhostable.net/api/files/$collectionName/$id/$file"

	wl-copy $image_link
else
	echo "Screenshot not taken. Exiting."
	exit 1
fi

exit 0
