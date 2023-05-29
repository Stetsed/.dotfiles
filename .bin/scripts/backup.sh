#!/bin/bash

# Script to backup my system using ZFS-send and then sending it to TrueNAS scale box using zfs-recieve

hostname=$(hostname)

if [[ hostname == "" ]]; then
	echo "Hostname is empty"
	exit 1
fi

if [[ $1 == "--help" || $1 == "" ]]; then
	echo "Usage: backup.sh backup [path] [--home|--root] [--reset]"
	echo "Note: Please give your user permission for send and snapshot for the dataset you want to backup."
	echo "Example: sudo zfs allow -u stetsed send,snapshot,mount,hold,destroy zroot/data/home"
	echo "Options:"
	echo "Path: Pass the path to the volume you want to backup. Ex: zroot/data/home"
	echo "--reset: Reset the backup and start from scratch"
	echo "--home : Checks which volume is mounted to /home and backs that up"
	echo "--root : Checks which volume is mounted to / and backs that up"
	exit 0
fi

if [[ $2 == "--home" ]]; then
	echo "Backing up /home"
	path=$(zfs list | grep '/home$' | awk '{print $1}')
	if [[ $path == "" ]]; then
		echo "No Volume Mounted to /home"
		exit 1
	fi
	path_name="home"
elif [[ $2 == "--root" ]]; then
	echo "Backing up /"
	path=$(zfs list | grep '/$' | awk '{print $1}')
	if [[ $path == "" ]]; then
		echo "No Volume Mounted to /"
		exit 1
	fi
	path_name="root"
elif [[ $2 == "--reset" ]]; then
	echo "Forgot to pass a path argument"
	exit 1
elif [[ $2 == "" ]]; then
	echo "No Path Selected"
	exit 1
else
	path=$2
	path_name=$(echo $path | awk -F "/" '{print $NF}')
fi

if [[ $1 == "backup" ]]; then
	echo "Backing up ${hostname}"
	if [[ -f ~/.backup_interrupted.lock && $2 != "--reset" ]]; then
		# Get the last snapshot that was interrupted
		echo "Running in Backup Interrupted Mode so trying to fetch resume token"
		trap "touch ~/.backup_interrupted.lock && exit" INT
		resume_token=$(ssh truenas "zfs get all Vault/backups/${hostname}-${path_name}" | grep receive | awk '{print $3}')
		zfs send -v -t "${resume_token}" | ssh truenas "zfs receive -F -s Vault/backups/${hostname}-${path_name}"
		rm ~/.backup_interrupted.lock
		exit 0
	else
		time=$(date +%Y-%m-%d-%H-%M-%S)

		permission=$(zfs snapshot -r $path@${time}-${hostname}-${path_name})

		if [[ permission == *"permission denied"* ]]; then
			echo "You do not have snapshot permissions, please make sure to give yourself these for the dataset aswell as send permission. Check --help"
			exit 1
		fi

		path_exists=$(ssh truenas "zfs list -H -o name Vault/backups/${hostname}-${path_name}" | wc -l)

		if [[ $3 == "--reset" || $path_exists == 0 ]]; then
			ssh truenas "zfs list -H -o name -t snapshot | grep "${hostname}-${path_name}" | xargs -n1 zfs destroy -r"
			ssh truenas "zfs destroy -r Vault/backups/${hostname}-${path_name}"
			trap "touch ~/.backup_interrupted.lock && exit " INT
			trap "zfs destroy $path@$time-$hostname-$path_name && exit" ERR
			zfs send -vw -R $path@${time}-${hostname}-${path_name} | ssh truenas "zfs receive -Fs Vault/backups/${hostname}-${path_name}"
			notify-send "Backup Complete"
			exit 0
		else
			trap "touch ~/.backup_interrupted.lock && exit " INT
			old_snapshot=$(zfs list -t snapshot -o name | grep ${path}@ | awk '{y=z; z=$0} END{print y}')
			trap "zfs destroy $path@$time-$hostname-$path_name && exit" ERR
			zfs send -vw -I ${old_snapshot} -R $path@${time}-${hostname}-${path_name} | ssh truenas "zfs receive -Fs Vault/backups/${hostname}-${path_name}"
			notify-send "Backup Complete"
			exit 0
		fi
	fi
else
	echo "Invalid option"
	exit 1
fi
