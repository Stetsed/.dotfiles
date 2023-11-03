#!/bin/bash

set -a
source ~/.env

if [[ $1 == "help" ]]; then
	echo "Usage: totp.sh [Directory]"
	echo "Directory: Directory containing .gpg files with 2FA secrets, you can use the enviroment variable TWOFA_DIRECTORY to set it without manually specifying it every time"
	echo "Example: totp.sh /home/user/2fa"
	echo "Uses GPG to decrypt the file and then uses oathtool to generate the code"
	exit 0
fi

TWOFA_DIRECTORY_USE=$TWOFA_DIRECTORY

if [ -z "$TWOFA_DIRECTORY_USE" ]; then
	TWOFA_DIRECTORY_USE=$1
	if [[ -z $TWOFA_DIRECTORY_USE ]]; then
		echo "No directory specified in command or enviroment variable"
		exit 1
	fi
fi

if [ ! "$(ls -A $TWOFA_DIRECTORY_USE)" ]; then
	echo "No files with .gpg extension found in $TWOFA_DIRECTORY_USE"
	exit 1
fi

for file in $TWOFA_DIRECTORY_USE/*.gpg; do
	echo "$(basename $file .gpg)"
	gpg --decrypt --quiet $file | oathtool -b --totp -
done
