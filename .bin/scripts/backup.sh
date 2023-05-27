#!/bin/bash

# Script to backup my system using ZFS-send and then sending it to TrueNAS scale box using zfs-recieve

# Use the GUM TUI package to present an option to ask if this is the first snapshot for this system.
echo "Is this the first snapshot on this system? This will decide if it will send a delta or a whole snapshot"
first_snapshot=$(gum choose "Y" "N")

time=$(date +%Y-%m-%d-%H-%M-%S)
hostname=$(hostname)

sudo zfs snapshot -r zroot/data/home@${time}-${hostname}

old_snapshot=$(zfs list -t snapshot | awk '{x=y; y=z; z=$0} END{print x}' | awk '{print $1}')

if [[ $first_snapshot == "Y" ]]; then
	sudo zfs send -vw zroot/data/home@${time}-${hostname} | ssh truenas "zfs receive -Fs Vault/backups/${hostname}"
	notify-send "Backup Complete"
elif [[ $first_snapshot == "N" ]]; then
	sudo zfs send -vw -I ${old_snapshot} zroot/data/home@${time}-${hostname} | ssh truenas "zfs receive -Fs Vault/backups/${hostname}"
	notify-send "Backup Complete"
else
	echo 'Selection made wrong'
fi
