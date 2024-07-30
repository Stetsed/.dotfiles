#!/bin/bash

type=$1
use=$2
area=$3

set -a
set -e
source ~/.env

time=$(date -u +%Y-%m-%dT%H:%M:%S%Z)

S3_ALIAS="$S3_IMAGE_ALIAS"
S3_BUCKET="$S3_IMAGE_BUCKET"
S3_WEB_LINK="$S3_WEB_LINK"

# Make it execute the below commands if the screenshot paramter is passed in $1

if [[ $type == "screenshot" ]]; then
	file_path=~/Documents/Screenshots/$time.png

	if [[ $area == "area" ]]; then
		~/.bin/scripts/grimblast.sh --notify save area $file_path
	elif [[ $area == "output" ]]; then
		~/.bin/scripts/grimblast.sh --notify save output $file_path
	elif [[ $area == "window" ]]; then
		~/.bin/scripts/grimblast.sh --notify save window $file_path
	fi

	if [[ -e $file_path ]]; then
		if [[ $2 == "copy" ]]; then
			wl-copy <$file_path
			notify-send "Copied to clipboard"
			exit 0
		elif [[ $2 == "upload" ]]; then
			RANDOM_STRING=$(
				tr -dc A-Za-z0-9 </dev/urandom | head -c 18
				echo ''
			)
			mcli cp $file_path "$S3_ALIAS/$S3_BUCKET/$RANDOM_STRING.png"
			IMAGE_LINK="https://$S3_BUCKET$S3_WEB_LINK/$RANDOM_STRING.png"
			wl-copy "$IMAGE_LINK"
			notify-send "Image Uploaded"
			exit 0
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
