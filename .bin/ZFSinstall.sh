#!/bin/bash

run ()
{
  sudo pacman -Syu --noconfirm gum

  clear

  Get_ZFS

  Partition_Drive

  Setup_Filesystem

  Setup_BaseSystem
}

Get_ZFS ()
{
  curl -s https://raw.githubusercontent.com/eoli3n/archiso-zfs/master/init | bash

  return
}

Partition_Drive ()
{
  sgdisk --zap-all /dev/disk/$SELECTED_DRIVE
  sgdisk -n1:0:+550M -t1:ef00 /dev/disk/by-id/$SELECTED_DRIVE
  sgdisk -n2:0:0 -t2:bf00 /dev/disk/by-id/$SELECTED_DRIVE

  mkfs.vfat /dev/disk/by-id/$SELECTED_DRIVE-part1

  return
}

Setup_Filesystem ()
{
 zpool create -O canmount=off -o ashift=12 zroot /dev/disk/by-id/$SELECTED_DRIVE-part2
 zfs create -o canmount=off -o mountpoint=none zroot/ROOT
 zfs create -o canmount=noauto -o mountpoint=/ zroot/ROOT/default
 zfs set compression=on zroot
 zfs set atime=off zroot
 zfs set xattr=sa zroot
 zfs set acltype=posixacl zroot
 zfs set autotrim=on zroot

 zfs create -o mountpoint=none zroot/data
 zfs create -o mountpoint=/home zroot/data/home

 zfs umount -a 
 zpool export zroot
 zpool import -d /dev/disk/by-id -R /mnt zroot

 zfs mount /zroot/ROOT/default
 zpool set bootfs=zroot/ROOT/default zroot

 mkdir /mnt/boot 
 mount /dev/disk/by-id/$SELECTED_DRIVE-part1 /mnt/boot
 mkdir /mnt/etc

 return
}

Setup_BaseSystem ()
{
  genfstab -U /mnt >> /mnt/etc/fstab

  pacstrap /mnt base base-devel linux linux-firmware nvim networkmanager intel-ucode

  arch-chroot /mnt
}

Select_Drive (){
  DRIVES=$(ls -1 /dev/disk/by-id/nvme-* | awk -F '/' '{printf "%s ", $NF}')
  SELECTED_DRIVE=$(gum choose --cursor-prefix "[ ] " --selected-prefix "[✓]" $DRIVES)

  return
}

run
