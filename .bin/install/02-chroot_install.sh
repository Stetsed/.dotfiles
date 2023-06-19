#!/bin/bash
Chroot_Run() {

	Chroot_Setup_ZFS

	Chroot_Install_Packages

	Chroot_User

	Chroot_Drivers

	Chroot_Setup_UKI

	Chroot_Final

	echo "Chroot Complete, you can exit with exit command"
	exit 0
}

Chroot_Setup_ZFS() {
	echo -e '[archzfs]\nServer = https://archzfs.com/$repo/$arch' >>/etc/pacman.conf
	pacman-key -r DDF7DB817396A49B2A2723F7403BD972F75D9D76
	pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76
	pacman -Syu
}

Chroot_Install_Packages() {
	pacman -S linux-headers zfs-dkms-git zfs-utils-git openssh networkmanager reflector
}

Chroot_User() {

	echo 'Enter Username You Wanna Use: '
	username=$(gum input --placeholder="stetsed")

	while [[ "$username" == "" ]]; do
		echo "Username cannot be empty, please enter again: "
		username=$(gum input --placeholder="stetsed")
	done

	password1="bruh"

	while [[ "$password1" != "$password2" ]]; do
		echo "Enter password and make sure it matches!"
		password1=$(gum input --placeholder="password" --password)
		password2=$(gum input --placeholder="password" --password)
	done

	while [[ "$shell" != "bash" && "$shell" != "fish" ]]; do
		echo "Which shell do you wanna use? (bash or fish): "
		shell=$(gum choose "bash" "fish")
	done

	if [[ $shell == "fish" ]]; then
		pacman -S fish
	fi

	useradd -m -G wheel -s /usr/bin/$shell $username
	(
		echo $password1
		echo $password1
	) | passwd $username
}

Chroot_Setup_UKI() {
	echo "zfs=zroot/ROOT/arch rw" >/etc/kernel/cmdline

	mkdir -p /boot/EFI/BOOT

	sed -i 's/keyboard keymap/keyboard zfs keymap/g' /etc/mkinitcpio.conf
	sed -i 's/default_image="\/boot\/initramfs-linux.img"/#&\ndefault_uki="\/boot\/EFI\/BOOT\/BOOTX64.EFI"/; s/fallback_image="/#&/' /etc/mkinitcpio.d/linux.preset
}

Chroot_Drivers() {
	echo -n 'Which GPU drivers do you want to use?'
	gpu=$(gum choose "Intel" "AMD" "NVIDIA")

	if [ "$gpu" == "Intel" ]; then
		pacman -S intel-media-driver
	elif [ "$gpu" == "AMD" ]; then
		pacman -S libva-mesa-driver mesa-vdpau
	elif [ "$gpu" == "NVIDIA" ]; then
		pacman -S nvidia nvidia-utils
	fi
}

Chroot_Final() {

	echo "en_US.UTF-8 UTF-8" >/etc/locale.gen
	locale-gen

	echo "LANG=en_US.UTF-8" >/etc/locale.conf

	echo -n 'What hostname do you wanna use(ex: archlinux): '
	hostname=$(gum input --placeholder="archlinux" --value="archlinux")

	echo $hostname >/etc/hostname

	zpool set cachefile=/etc/zfs/zpool.cache zroot

	systemctl enable NetworkManager

	echo "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers

	systemctl enable zfs-scrub-weekly@zroot.timer
	systemctl enable zfs.target
	systemctl enable zfs-import-cache
	systemctl enable zfs-mount
	systemctl enable reflector.timer
	zgenhostid $(hostid)

	mkinitcpio -P
}

Chroot_Run
