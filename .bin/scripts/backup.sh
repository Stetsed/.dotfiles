#!/bin/bash

# Script to backup my system using ZFS-send and then sending it to TrueNAS scale box using zfs-recieve

set -a

cmd=$1
path=$2
reset=$3

help() {
	echo "Usage: backup.sh [backup|permissions|reset] [path]"
	echo "Note: Please give your user permission for send and snapshot for the dataset you want to backup."
	echo "Options:"
	echo "reset: Reset the backup and start from scratch."
	echo "permissions: Give your user permission for send and snapshot for the dataset you want to backup."
	echo "path: Pass the path to the volume you want to backup. Ex: zroot/data/home"
	exit 0
}

set_variables() {
	hostname=$(hostname)

	if [[ hostname == "" ]]; then
		echo "Hostname is empty"
		exit 1
	fi

	if [[ $path == "" ]]; then
		echo "No Path Selected"
		exit 1
	else
		path=$path
		path_name=$(echo $path | awk -F "/" '{print $NF}')
	fi
}

backup() {
	echo "Backing up ${hostname}"
	if [[ -f ~/.backup_interrupted.lock && $reset != "--reset" ]]; then
		backup_interrupted
	else
		time=$(date +%Y-%m-%d-%H-%M-%S)

		permission=$(zfs snapshot -r $path@${time}-${hostname}-${path_name})

		if [[ permission == *"permission denied"* ]]; then
			echo "You do not have snapshot permissions, please make sure you have the correct permissions and have ran the permissions function."
			exit 1
		fi

		path_exists=$(ssh truenas "zfs list -H -o name Vault/backups/${hostname}-${path_name}" | wc -l)

		if [[ $path_exists == 0 ]]; then
			backup_new
		else
			backup_normal
		fi
	fi
}

backup_interrupted() {
	echo "Running in Backup Interrupted Mode so trying to fetch resume token"
	trap "touch ~/.backup_interrupted.lock && notify-send 'Backup Failed' && exit" INT ERR
	resume_token=$(ssh truenas "zfs get all -r Vault/backups/$hostname-$path" | grep resume | awk '{print $3}')
	zfs send -ve -t "${resume_token}" | ssh truenas "zfs receive -F -s Vault/backups/${hostname}-${path_name}"
	rm ~/.backup_interrupted.lock
	exit 0
}

backup_new() {
	trap "touch ~/.backup_interrupted.lock && notify-send 'Backup Failed' && exit " INT ERR
	zfs send -vwe -R $path@${time}-${hostname}-${path_name} | ssh truenas "zfs receive -Fs Vault/backups/${hostname}-${path_name}"
	notify-send "Backup Complete"
	exit 0
}

backup_normal() {
	trap "touch ~/.backup_interrupted.lock && exit " INT
	old_snapshot=$(zfs list -t snapshot -o name | grep ${path}@ | awk '{y=z; z=$0} END{print y}')
	trap "touch ~/.backup_interrupted.lock && notify-send 'Backup Failed' && exit " INT ERR
	zfs send -vwe -I ${old_snapshot} -R $path@${time}-${hostname}-${path_name} | ssh truenas "zfs receive -Fs Vault/backups/${hostname}-${path_name}"
	notify-send "Backup Complete"
	exit 0
}

permissions() {
	echo "Giving permissions to user for send and snapshot"
	sudo zfs allow -u $(whoami) send,snapshot,mount,hold,destroy $path
	exit 0
}

reset() {
	ssh truenas "zfs list -H -o name -t snapshot | grep "${hostname}-${path_name}" | xargs -n1 zfs destroy -R"
	ssh truenas "zfs destroy -Rr Vault/backups/${hostname}-${path_name}"
	exit 0
}

if [[ $cmd == "--help" || $1 == "" ]]; then
	help
fi

set_variables

if [[ $cmd == "backup" ]]; then
	backup
elif [[ $cmd == "permissions" ]]; then
	permissions
elif [[ $cmd == "reset" ]]; then
	reset
else
	echo "Invalid option"
	exit 1
fi
