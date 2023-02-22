#!/bin/bash

Setup_ZFS ()
{
  echo -e "[archzfs]\nServer = https://archzfs.com/$repo/$arch" >> /etc/pacman.conf
  pacman-key -r DDF7DB817396A49B2A2723F7403BD972F75D9D76
  pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76
  pacman -Syu
}

Install_Packages ()
{
  pacman -S linux-headers zfs-dkms openssh networkmanager
}

user ()
{
  useradd -m -G wheel -S /usr/bin/fish stetsed
  echo "BlahBlah" | passwd stetsed -stdin
}

final ()
{
  zpool set cachefile=/etc/zfs/zpool.cache zroot

  bootctl install 

  echo -e "title Arch Linux\nlinux vmlinuz-linux\ninitrd intel-ucode.img\ninitrd initramfs-linux.img\noptions zfs=zroot/ROOT/default rw" > /boot/loader/entries/arch.conf

  echo "default arch" >> /boot/loader/loader.conf
}
