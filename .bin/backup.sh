#!/bin/bash

HOSTNAME=$(cat /etc/hostname)
DATE=$(date '+%F')

cd ~/

rsync -aAXv --delete --exclude '.cache' ./ /mnt/data/Backup/$HOSTNAME/$DATE
