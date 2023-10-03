#!/bin/bash

type=$1

set -a
source ~/.env
set +a

time=$(date -u +%Y-%m-%dT%H:%M:%S%Z)

S3_ALIAS="image-storage"
S3_BUCKET="$S3_BUCKET"
S3_WEB_LINK="$S3_WEB_LINK"

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
			RANDOM_IMAGE_STRING=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
			mcli cp $file_path "$S3_ALIAS/$S3_BUCKET/$RANDOM_IMAGE_STRING.png"
			IMAGE_LINK="https://$S3_BUCKET.$S3_WEB_LINK/$RANDOM_IMAGE_STRING.png"
			wl-copy $IMAGE_LINK
			notify-send "Image Uploaded"
		fi
	else
		echo "Screenshot not taken. Exiting."
		exit 1
	fi
elif [[ $type == "video" ]]; then
	file_path=~/Network/Documents/Videos/$time.mp4

	card_entry=$(/usr/bin/ls /dev/dri | grep -E "card[0-9]+" | head -n 1)

	eww open recording

	notify-send -t 5000 "Starting Recording..."

	wf-recorder -c h264_vaapi -f $file_path

	eww close recording

	notify-send "Video Taken $file_path"

	if [[ $2 == "copy" ]]; then
		wl-copy <$file_path
		notify-send "Copied to clipboard"
		exit 0
	elif [[ $2 == "upload" ]]; then
		RANDOM_VIDEO_STRING=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
		mcli cp $file_path "$S3_ALIAS/$S3_BUCKET/$RANDOM_VIDEO_STRING.mp4"
		VIDEO_LINK="https://$S3_BUCKET.$S3_WEB_LINK/$RANDOM_VIDEO_STRING.mp4"
		wl-copy $VIDEO_LINK
		notify-send "Video Uploaded"
	fi
fi

exit 0
