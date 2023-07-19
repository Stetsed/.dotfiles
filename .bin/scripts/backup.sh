#!/bin/bash

# Script to backup my system using ZFS-send and then sending it to TrueNAS scale box using zfs-recieve
# Currently this script doesn't support resuming backups although the code does work, but due to the Arch version of ZFS and the TrueNAS version of ZFS not being the same it sadly doesn't work.

set -a

cmd=$1
path=$2
reset=$3

readonly BACKUP_HOST="truenas.hosts.selfhostable.net"

help() {
	echo "Usage: backup.sh [backup|permissions|reset] [path] [--all]"
	echo "Note: Please give your user permission for send and snapshot for the dataset you want to backup."
	echo "Options:"
	echo "reset: Reset the backup and start from scratch."
	echo "permissions: Give your user permission for send and snapshot for the dataset you want to backup."
	echo "path: Pass the path to the volume you want to backup. Ex: zroot/data/home"
	echo "all: Backup from the first snapshot to the most recent one"
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
	if [[ $1 == "RemoveThisLaterYouFuckHeadThisIsJustTemp" ]]; then
		#backup_interrupted
		echo 'f off'
	else
		time=$(date +%Y-%m-%d-%H-%M-%S)

		if [[ -f ~/.backup_interrupted.lock ]]; then
			transfer_snapshot=$(zfs list -t snapshot -o name | grep ${path}@ | awk '{z=$0} END{print z}')
		else
			permission=$(zfs snapshot -r $path@${time}-${hostname}-${path_name})

			if [[ permission == *"permission denied"* ]]; then
				echo "You do not have snapshot permissions, please make sure you have the correct permissions and have ran the permissions function."
				exit 1
			fi

			transfer_snapshot="$path@${time}-${hostname}-${path_name}"
		fi

		path_exists=$(ssh ${BACKUP_HOST} "zfs list -H -o name Vault/backups/${hostname}-${path_name}" | wc -l)

		if [[ $path_exists == 0 ]]; then
			if [[ $3 == "--all" ]]; then
				backup_all
			else
				backup_new
			fi
		elif [[ $path_exists > 0 && $3 == "--all" ]]; then
			echo "--all only works when nothing exists"
			exit 1
		elif [[ $path_exists > 0 ]]; then
			backup_incremental
		fi
	fi
}

#backup_interrupted() {
#	echo "Running in Backup Interrupted Mode so trying to fetch resume token"
#	trap "touch ~/.backup_interrupted.lock && notify-send 'Backup Failed' && exit" INT ERR
#	resume_token=$(ssh ${BACKUP_HOST} "zfs get all -r Vault/backups/$hostname-$path" | grep resume | awk '{print $3}')
#	zfs send -ve -t "${resume_token}" | ssh ${BACKUP_HOST} "zfs receive -F -s Vault/backups/${hostname}-${path_name}"
#	rm ~/.backup_interrupted.lock
#	exit 0
#}

backup_new() {
	echo "Making a new backup with the screenshot made."
	trap "touch ~/.backup_interrupted.lock && notify-send 'Backup Failed' && exit " INT ERR
	zfs send -vwe -R ${transfer_snapshot} | ssh ${BACKUP_HOST} "zfs receive -F Vault/backups/${hostname}-${path_name}"
	notify-send "Backup Complete"
	rm ~/.backup_interrupted.lock
	exit 0
}

backup_all() {
	echo "Backing up the first ever snapshot first on the path, and then doing an incrmenetal backup to the most recent snapshot."
	trap "touch ~/.backup_interrupted.lock && notify-send 'Backup Failed' && exit " INT ERR
	old=$(zfs list -t snapshot -o name | grep ${path}@ | head -n 1)
	zfs send -vwe -R $old | ssh ${BACKUP_HOST} "zfs receive -F Vault/backups/${hostname}-${path_name}"
	zfs send -vwe -I ${old} -R ${transfer_snapshot} | ssh ${BACKUP_HOST} "zfs receive -F Vault/backups/${hostname}-${path_name}"
	notify-send "Backup Complete"
	rm ~/.backup_interrupted.lock
	exit 0
}

backup_incremental() {
	echo "Getting Latest Snapshot Available on Server and checking if it exists on client"
	server_latest_snapshot=$(ssh ${BACKUP_HOST} "zfs list -H -t snapshot -o name" | grep ${hostname}-${path_name}@ | awk '{z=$0} END{print z}' | cut -d '@' -f2)
	does_snapshot_exist=$(zfs list -t snapshot -o name | grep ${path}@ | grep $server_latest_snapshot | wc -l)
	if [[ $does_snapshot_exist == 0 ]]; then
		echo "The latest snapshot on the server doesn't exist on the client, this usually means that you are trying to backup to a location thats already taken. If this is not the case and you are sure use the reset command to wipe it and then do a backup."
		exit 1
	fi
	old_snapshot=$(zfs list -t snapshot -o name | grep ${path}@ | grep ${server_latest_snapshot})
	echo "Backing up from $old_snapshot to $transfer_snapshot"
	trap "touch ~/.backup_interrupted.lock && notify-send 'Backup Failed' && exit " INT ERR
	zfs send -vwe -I ${old_snapshot} -R ${transfer_snapshot} | ssh ${BACKUP_HOST} "zfs receive -F Vault/backups/${hostname}-${path_name}"
	notify-send "Backup Complete"
	exit 0
}

permissions() {
	echo "Giving permissions to user for send and snapshot"
	sudo zfs allow -u $(whoami) send,snapshot,mount,hold,destroy $path
	exit 0
}

reset() {
	echo "Resetting Backup"
	ssh ${BACKUP_HOST} "zfs list -H -o name -t snapshot | grep "${hostname}-${path_name}" | xargs -n1 zfs destroy -R"
	ssh ${BACKUP_HOST} "zfs destroy -Rr Vault/backups/${hostname}-${path_name}"
	exit 0
}

if [[ $cmd == "--help" || $1 == "" ]]; then
	help
fi

set_variables

if [ ${cmd} == "backup" ]; then
	backup
elif [ ${cmd} == "permissions" ]; then
	permissions
elif [ ${cmd} == "reset" ]; then
	reset
else
	echo "Invalid option"
	exit 1
fi
