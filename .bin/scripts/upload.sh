#!/bin/bash

set -a
set -e
if [[ $1 == "help" ]]; then
	echo "Usage: upload.sh <file> or pipe to upload.sh"
	echo "  Uploads a file to the server"
	echo "  If no file is specified, reads from stdin and upload to HasteBin"
	exit 0
fi

# Check if the HASTEBIN_URL environment variable is set
if [[ -z $HASTEBIN_URL && $# -eq 0 ]]; then
	echo "Error: HASTEBIN_URL is not set. Please set the environment variable with the URL of the hastebin server."
	exit 1
fi

# Check if a file is provided as an argument
if [[ $# -eq 1 ]] && [[ -f $1 ]]; then
	echo "Todo Reimplement this shit you fuck"

elif [ ! -t 0 ]; then
	# If stdin is not empty, read from stdin and perform a POST request
	response=$(curl -sS -X POST -H "Content-Type: text/plain" --data-binary "@-" "$HASTEBIN_URL/documents")

	# Extract the key from the response JSON
	key=$(echo "$response" | jq -r '.key')

	if [[ -z $key ]]; then
		echo "Error: Failed to extract key from response."
		exit 1
	fi

	# Construct the URL using the extracted key
	result_url="$HASTEBIN_URL/$key"
	wl-copy $result_url
else
	echo "Error: No valid input detected. Please provide a file or input via stdin."
	exit 1
fi
