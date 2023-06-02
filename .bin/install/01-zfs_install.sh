#!/bin/bash

ZFS_Run() {

	ZFS_Select_Drive

	if [ "$SELECTED_DRIVE" == "" ]; then
		echo "No drive selected, exiting"
		exit 0
	fi

  echo "Are you running an ISO with ZFS installed?"
  zfs_iso=$(gum choose "Yes" "No")

  if [[ $zfs_iso == "No" ]]; then
    ZFS_Get_ZFS
  fi

	ZFS_Partition_Drive

	ZFS_Setup_Filesystem

	ZFS_Setup_Basesystem

	exit 0
}

ZFS_Select_Drive() {
	echo "Choose the drive you want to install on."
	DRIVES=$(ls -1 /dev/disk/by-id/nvme-* | awk -F '/' '{printf "%s ", $NF}')
	SELECTED_DRIVE=$(gum choose --cursor-prefix "[ ] " --selected-prefix "[✓]" $DRIVES)

	return
}

ZFS_Get_ZFS() {
	echo "Installing the ArchISO ZFS Package"
	curl -s https://raw.githubusercontent.com/eoli3n/archiso-zfs/master/init | bash

	return
}

ZFS_Partition_Drive() {
	zpool labelclear -f /dev/disk/by-id/$SELECTED_DRIVE

	blkdiscard -f /dev/disk/by-id/$SELECTED_DRIVE
	sleep 10

	sgdisk -n1:0:+550M -t1:ef00 /dev/disk/by-id/$SELECTED_DRIVE
	sgdisk -n2:0:0 -t2:bf00 /dev/disk/by-id/$SELECTED_DRIVE

	sleep 10

	mkfs.vfat /dev/disk/by-id/$SELECTED_DRIVE-part1

	return

}

ZFS_Setup_Filesystem() {
	echo -e "Do you want to encrypt your drive"
	encrypt=$(gum choose "Yes" "No")

	if [[ $encrypt == "Yes" ]]; then
		zpool create -f -O atime=off -O acltype=posixacl -O xattr=sa -O compression=lz4 -O canmount=off -o ashift=12 -O encryption=aes-256-gcm -O keyformat=passphrase -O keylocation=prompt zroot /dev/disk/by-id/$SELECTED_DRIVE-part2
	else
		zpool create -f -O atime=off -O acltype=posixacl -O xattr=sa -O compression=lz4 -O canmount=off -o ashift=12 zroot /dev/disk/by-id/$SELECTED_DRIVE-part2
	fi

	zfs create -o canmount=off -o mountpoint=none zroot/ROOT

	zfs create -o canmount=noauto -o mountpoint=/ zroot/ROOT/arch

	zfs create -o mountpoint=none zroot/data
	zfs create -o mountpoint=/home zroot/data/home

	zfs umount -a
	zpool export zroot

	zpool import -l -d /dev/disk/by-id -R /mnt zroot

	zfs mount zroot/ROOT/arch
	zfs mount zroot/data/home
	zpool set bootfs=zroot/ROOT/arch zroot

	mkdir /mnt/boot
	mount /dev/disk/by-id/$SELECTED_DRIVE-part1 /mnt/boot
	mkdir /mnt/etc

	return
}

ZFS_Setup_Basesystem() {

	echo -n 'Do you use AMD or INTEL(ex: intel/amd): '
	cpu=$(gum choose "intel" "amd")

	while [[ "$cpu" != "intel" && "$cpu" != "amd" ]]; do
		echo -n 'Please select a CPU'
		cpu=$(gum choose "intel" "amd")
	done

	genfstab -U /mnt >>/mnt/etc/fstab

	pacstrap /mnt base base-devel linux linux-firmware neovim networkmanager $cpu-ucode

	arch-chroot /mnt bash -c "$(curl -Ls selfhostable.net/install)"

	arch-chroot /mnt

	umount -R /mnt

	zfs umount -a

	zpool export zroot

	echo "Installation Complete, Please Reboot"

	return
}

ZFS_Run
