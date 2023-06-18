#!/bin/bash

Backup_Select_Drive() {
	echo "Choose the drive you want to install on."
	DRIVES=$(ls -1 /dev/disk/by-id/nvme-* | awk -F '/' '{printf "%s ", $NF}')
	SELECTED_DRIVE=$(gum choose --cursor-prefix "[ ] " --selected-prefix "[✓]" $DRIVES)

	return
}

Backup_Get_ZFS() {
	echo "Installing the ArchISO ZFS Package"
	curl -s https://raw.githubusercontent.com/eoli3n/archiso-zfs/master/init | bash

	return
}

Backup_Select_Backup() {
	ssh truenas "echo 'Test SSH Connection'"

	if [ $? -ne 0 ]; then
		echo "SSH Connection Failed. Make sure you have setup your SSH key and SSH config to the truenas ssh."
		exit 1
	fi

	backups=$(ssh truenas "zfs list -H -o name -t filesystem | grep Vault/backups | awk -F'/' 'NF==3'")

	SELECTED_BACKUP=$(gum choose $backups)

	if [ "$SELECTED_BACKUP" == "" ]; then
		echo "No backup selected, exiting"
		exit 0
	fi
}

Backup_Partition_Drive() {
	zpool labelclear -f /dev/disk/by-id/$SELECTED_DRIVE

	blkdiscard -f /dev/disk/by-id/$SELECTED_DRIVE
	sleep 10

	sgdisk -n1:0:+550M -t1:ef00 /dev/disk/by-id/$SELECTED_DRIVE
	sgdisk -n2:0:0 -t2:bf00 /dev/disk/by-id/$SELECTED_DRIVE

	sleep 10

	mkfs.vfat /dev/disk/by-id/$SELECTED_DRIVE-part1

	return

}

Backup_Setup_ZPool() {
	echo -e "Do you want to encrypt your drive"
	encrypt=$(gum choose "Yes" "No")

	if [[ $encrypt == "Yes" ]]; then
		zpool create -f -O atime=off -O acltype=posixacl -O xattr=sa -O compression=lz4 -O canmount=off -o ashift=12 -O encryption=aes-256-gcm -O keyformat=passphrase -O keylocation=prompt zroot /dev/disk/by-id/$SELECTED_DRIVE-part2
	else
		zpool create -f -O atime=off -O acltype=posixacl -O xattr=sa -O compression=lz4 -O canmount=off -o ashift=12 zroot /dev/disk/by-id/$SELECTED_DRIVE-part2
	fi

}

Backup_Restore_System() {
	echo "Restoring $SELECTED_BACKUP to $SELECTED_DRIVE"
	ssh truenas "zfs send -R $SELECTED_BACKUP" | zfs recv -Fdu zroot
	echo "Restore Complete"
}

Backup_Mount() {
	zpool export zroot

	zpool import -l -d /dev/disk/by-id -R /mnt zroot

	zfs mount zroot/ROOT/arch

	mkdir /mnt/boot
	mount /dev/disk/by-id/$SELECTED_DRIVE-part1 /mnt/boot
	mkdir /mnt/etc

	genfstab -U /mnt >>/mnt/etc/fstab

	echo "You will now be dropped into the chroot session, please run mkinitcpio -P to generate the UKI and then assuming everything went fine you should be able to reboot"
}

Backup_Run() {

	Backup_Select_Drive

	if [ "$SELECTED_DRIVE" == "" ]; then
		echo "No drive selected, exiting"
		exit 0
	fi

	echo "Checking if ZFS is enabled in this ISO"
	if ! pacman -Qi zfs-utils >/dev/null; then
		echo "ZFS is not installed, installing"
		ZFS_Get_ZFS
	fi

	modprobe zfs

	Backup_Select_Backup

	Backup_Partition_Drive

	Backup_Setup_ZPool

	Backup_Restore_System

	exit 0
}
