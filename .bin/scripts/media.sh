#!/bin/bash

# HOW TO USE
# 1. Create a collection named "images" in PocketBase
# 2. Copy the API key from PocketBase Local Storage
# 3. Create a file named ".env" in your home directory
# 4. Paste the API key in the .env file with the following format: AUTHORIZATION="(API key)"
# 5. Make the file executable with the following command: chmod +x media.sh
# 6. Update the URL's to match your pocketbase instance. So you want to replace pocketbase.selfhostable.net

type=$1

set -a
source ~/.env
set +a

time=$(date -u +%Y-%m-%dT%H:%M:%S%Z)

# Make it execute the below commands if the screenshot paramter is passed in $1

if [[ $type == "screenshot" ]]; then
	file_path=~/Network/Documents/Screenshots/$time.png

	~/.bin/scripts/grimblast.sh --notify save area $file_path

	if [[ -e $file_path ]]; then
		if [[ $2 == "copy" ]]; then
			wl-copy <$file_path
			notify-send "Copied to clipboard"
			exit 0
		elif [[ $2 == "upload" ]]; then
			json=$(curl -X POST -H "Authorization: $AUTHORIZATION_POCKETBASE" https://pocketbase.selfhostable.net/api/collections/upload/records --form "file=@\"$file_path\"")

			responseError=$(echo "$json" | jq -r '.code')

			if [[ $responseError == "403" ]]; then
				notify-send -t 5000 "Authorization Token has probally expired douche bag."
				exit 1
			fi

			collectionName=$(echo "$json" | jq -r '.collectionName')
			id=$(echo "$json" | jq -r '.id')
			file=$(echo "$json" | jq -r '.file')

			image_link="https://pocketbase.selfhostable.net/api/files/$collectionName/$id/$file"

			wl-copy $image_link
		fi
	else
		echo "Screenshot not taken. Exiting."
		exit 1
	fi
elif [[ $type == "video" ]]; then
	file_path=~/Network/Documents/Videos/$time.mp4

	eww open recording

	notify-send -t 5000 "Starting Recording..."

	wf-recorder -c h264_vaapi -d /dev/dri/card0 -t -f $file_path

	eww close recording

	notify-send "Video Taken $file_path"

	if [[ $2 == "copy" ]]; then
		wl-copy <$file_path
		notify-send "Copied to clipboard"
		exit 0
	fi

	json=$(curl -X POST -H "Authorization: $AUTHORIZATION_POCKETBASE" https://pocketbase.selfhostable.net/api/collections/upload/records --form "file=@\"$file_path\"")

	responseError=$(echo "$json" | jq -r '.code')

	if [[ $responseError == "403" ]]; then
		notify-send -t 5000 "Authorization Token has probally expired douche bag."
		exit 1
	fi

	collectionName=$(echo "$json" | jq -r '.collectionName')
	id=$(echo "$json" | jq -r '.id')
	file=$(echo "$json" | jq -r '.file')

	image_link="https://pocketbase.selfhostable.net/api/files/$collectionName/$id/$file"

	wl-copy $image_link

fi

exit 0
