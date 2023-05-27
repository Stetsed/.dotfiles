#!/bin/bash

# Script to backup my system using ZFS-send and then sending it to TrueNAS scale box using zfs-recieve

hostname=$(hostname)

if [[ hostname == "" ]]; then
	echo "Hostname is empty"
	exit 1
fi

if [ -f ~/.backup_interrupted.lock ]; then
	# Get the last snapshot that was interrupted
	echo "Running in Backup Interrupted Mode so trying to fetch resume token"
	resume_token=$(ssh truenas "zfs get all Vault/backups/${hostname}" | grep receive | awk '{print $3}')
	sudo zfs send -v -t "${resume_token}" | ssh truenas "zfs receive -F -s Vault/backups/${hostname}"
	rm ~/.backup_interrupted.lock
else
	# Use the GUM TUI package to present an option to ask if this is the first snapshot for this system.
	echo "Is this the first snapshot on this system? This will decide if it will send a delta or a whole snapshot"
	first_snapshot=$(gum choose "Y" "N")

	time=$(date +%Y-%m-%d-%H-%M-%S)

	sudo zfs snapshot -r zroot/data/home@${time}-${hostname}

	if [[ $first_snapshot == "Y" ]]; then
		trap "touch ~/.backup_interrupted.lock && exit " INT EXIT
		ssh truenas "zfs list -H -o name -t snapshot | grep "${hostname}" | xargs -n1 zfs destroy -r"
		ssh truenas "zfs destroy -r Vault/backups/${hostname}"
		sudo zfs send -vw zroot/data/home@${time}-${hostname} | ssh truenas "zfs receive -Fs Vault/backups/${hostname}"
		notify-send "Backup Complete"
	elif [[ $first_snapshot == "N" ]]; then
		trap "touch ~/.backup_interrupted.lock && exit " INT EXIT
		old_snapshot=$(zfs list -t snapshot -o name | awk '{y=z; z=$0} END{print y}')
		sudo zfs send -vw -I ${old_snapshot} zroot/data/home@${time}-${hostname} | ssh truenas "zfs receive -Fs Vault/backups/${hostname}"
		notify-send "Backup Complete"
	else
		echo 'Selection made wrong'
	fi
fi
