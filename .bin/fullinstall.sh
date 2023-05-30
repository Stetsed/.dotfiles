#!/usr/bin/env bash

ZFS_Run() {

	ZFS_Select_Drive

	if [ "$SELECTED_DRIVE" == "" ]; then
		echo "No drive selected, exiting"
		exit 0
	fi

	ZFS_Get_ZFS

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

	while [[ encrypt == "" ]]; do
		echo "Do you want to encrypt your drive?"
		encrypt=$(gum choose "Yes" "No")
	done

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

	arch-chroot /mnt sh -c "$(curl -Ls selfhostable.net/install)"

	arch-chroot /mnt

	umount -R /mnt

	zfs umount -a

	zpool export zroot

	echo "Installation Complete, Please Reboot"

	return
}

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
	pacman -S linux-headers zfs-dkms-git openssh networkmanager reflector
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

User_Run() {

	User_Home

	User_Paru

	User_Dotfiles

	User_Packages

	User_Extra

	echo -n 'Are you Stetsed and do you wanna use Stetsed Specific Configuration for Storage: '
	isstetsed=$(gum choose "Yes" "No")

	if [[ $isstetsed == "Yes" ]]; then
		User_Stetsed
	fi

	echo -n 'Program is Finished Executing, have a wonderful day :D'
	exit 0
}

User_Home() {
	username=$(whoami)

	sudo mkdir /home/$username

	sudo chown $username:$username -R /home/$username

	sudo chmod 700 -R /home/$username

	cd /home/$username
}

User_Paru() {
	sudo pacman -Syu git

	git clone https://aur.archlinux.org/paru-bin.git

	cd paru-bin

	makepkg -s

	sudo pacman -U paru-bin*

	cd ..

	rm -rf paru-bin
}

User_Dotfiles() {
	echo -n 'Note: This installation expects your dotfiles to be in a bare repository, and expects there to be a .packages.list file in the root of the repository, which has 1 package per line.'
	echo -n 'Enter the Github Repository you wanna use: '
	repository=$(gum input --placeholder "stetsed/.dotfiles")

	git clone --bare https://github.com/$repository.git $HOME/.dotfiles
	function config {
		/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
	}
	config checkout -f
	config config status.showUntrackedFiles no
	config remote set-url origin git@github.com:$repository.git
}

User_Packages() {
	if [[ -f .packages.list ]]; then
		mapfile -t names <.packages.list
		paru -Syu ${names[@]} --needed
	else
		echo "No .packages.list file found. Skipping package installation."
	fi
}

User_Extra() {
	echo -n 'To enable the bluetooth package you require the bluez package installed, and for pipewire you need pipewire and pipewire-pulse installed``'

	echo -n 'Do you wanna install enable bluetooth?'
	bluetooth=$(gum choose "Yes" "No")

	echo -n 'Do you want to enable pipewire?'
	pipewire=$(gum choose "Yes" "No")

	if [[ $bluetooth == "Yes" ]]; then
		systemctl enable --now bluetooth
	fi

	if [[ $pipewire == "Yes" ]]; then
		systemctl --user enable --now pipewire
		systemctl --user enable --now pipewire-pulse
	fi

	username=$(whoami)

	sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
	echo -e "[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin $username --noclear %I $TERM" | sudo tee -a /etc/systemd/system/getty@tty1.service.d/skip-prompt.conf
	sudo systemctl enable getty@tty1.service

	while [[ $time != "y" && $time != "n" ]]; do
		echo -n 'Do you want to set the time to the correct timezone and enable timesyncd? (y/n): '
		read time
	done

	if [[ $time == "y" ]]; then
		echo -n 'When entering timezone please use the following format: Region/City with correct capitalization.'
		timezone=$(gum input --placeholder "Europe/Amsterdam")

		sudo systemctl enable --now systemd-timesyncd.service
		timedatectl set-ntp true
		timedatectl set-timezone $timezone
	fi

}

User_Stetsed() {
	echo "10.4.78.251:/mnt/Vault/Storage /mnt/data nfs defaults,_netdev,x-systemd.automount,x-systemd.mount-timeout=10,noauto 0 0" | sudo tee -a /etc/fstab
	sudo mkdir /mnt/data

	mkdir ~/Network
	ln -s /mnt/data/Stetsed/Storage ~/Network/Storage
	ln -s /mnt/data/Stetsed/Documents ~/Network/Documents
	mkdir Downloads

	systemctl mask NetworkManager-wait-online.service

}

File_Run() {

	echo "Would you like to transfer files from the server, or too the server."
	TOO="To the Server"
	FROM="From the Server"
	TRANSFER_SELECTION=$(gum choose "$TOO" "$FROM")
	grep -q "$TOO" <<<"$TRANSFER_SELECTION" && File_Too
	grep -q "$FROM" <<<"$TRANSFER_SELECTION" && File_From
}

File_Too() {
	pkill librewolf
	pkill webcord

	cp -r ~/.librewolf ~/Network/Storage/Transfer/

	rm -rf ~/.config/WebCord/Cache/

	cp -r ~/.config/WebCord ~/Network/Storage/Transfer/

	cp -r ~/.ssh ~/Network/Storage/Transfer/

	cp -r ~/.env ~/Network/Storage/Transfer/
	exit
}

File_From() {
	pkill librewolf
	pkill webcord

	rm -rf ~/.librewolf
	mv ~/Network/Storage/Transfer/.librewolf ~/

	rm -rf ~/.config/WebCord
	mv ~/Network/Storage/Transfer/WebCord ~/.config/

	rm -rf ~/.ssh
	mv ~/Network/Storage/Transfer/.ssh ~/

	rm -rf ~/.env
	mv ~/Network/Storage/Transfer/.env ~/

	gpg --import ~/Network/Storage/Long-Term/stetsed.asc
}

Extra_Run() {
	SERVER_SETUP="Server Setup"
	ZFS_REMOTE_UNLOCK="ZFS Remote Unlock Setup"
	FRAMEWORK_TLP="Framework TLP Setup"
	FRAMEWORK_80_100="Framework 80/100 Power Setup"
	FRAMEWORK_FINGERPRINT="Framework Fingerprint Setup"
	SELECTION=$(gum choose "$SERVER_SETUP" "$ZFS_REMOTE_UNLOCK" "$FRAMEWORK_TLP" "$FRAMEWORK_80_100" "$FRAMEWORK_FINGERPRINT")
	grep -q "$SERVER_SETUP" <<<"$SELECTION" && Server_Setup
	grep -q "$ZFS_REMOTE_UNLOCK" <<<"$SELECTION" && ZFS_Remote_Unlock_Setup
	grep -q "$FRAMEWORK_TLP" <<<"$SELECTION" && Framework_TLP_Setup
	grep -q "$FRAMEWORK_80_100" <<<"$SELECTION" && Framework_80_100_Setup
	grep -q "$FRAMEWORK_FINGERPRINT" <<<"$SELECTION" && Framework_Fingerprint_Setup
}

Server_Setup() {
	source /etc/os-release

	if [[ $ID == "debian" ]]; then
		Server_Setup_Debian
	elif [[ $ID == "arch" ]]; then
		Server_Setup_Arch
	else
		echo "Unsupported operating system: $ID"
	fi
}

Server_Setup_Arch() {
	sudo pacman -Syu kitty fish starship
	sudo chsh -s /usr/bin/fish
	echo "Please exit this terminal with the exit command, this is to generate the fish start config"
	fish
	echo "starship init fish | source" >>~/.config/fish/config.fish

	mkdir -p ~/.config/fish/functions
	curl -sL https://raw.githubusercontent.com/Stetsed/.dotfiles/main/.config/fish/functions/nano.fish >~/.config/fish/functions/nano.fish
}

Server_Setup_Debian() {
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	ln -s ~/.local/kitty.app/bin/kitty /bin/kitty
	ln -s ~/.local/kitty.app/bin/kitten /bin/kitten

	sudo chsh -s /usr/bin/fish

	curl -sS https://starship.rs/install.sh | sh

	echo "Please exit this terminal with the exit command, this is to generate the fish start config"
	fish
	echo "starship init fish | source" >>~/.config/fish/config.fish

	mkdir -p ~/.config/fish/functions
	curl -sL https://raw.githubusercontent.com/Stetsed/.dotfiles/main/.config/fish/functions/nano.fish >~/.config/fish/functions/nano.fish
}

ZFS_Remote_Unlock_Setup() {
	yay -Syu mkinitcpio-netconf mkinitcpio-dropbear

	echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIezEg3z8pf+9ZoQlscHCrKd72d2sZMtEFyEIZjqSX3uJa0RfHK7miIBXqOEv8A8dlAwUlOP3n+A77TbY6FM5DAM/EFZ4v2Qxz8AJeCJN5YWm+WxE7+NNMIAt88WBtPuNNAmLgnLP10izAjnSJpHU1xc2nW49FoscI5VeoBUCr6UFbgsTqxBWwBBXjCF0dbAh6G1B6zRPkcfhes2aGpnvjrRYDsk3nfzsfMQgsrBrTmehNJDIDiEOQeBwnwsopkMBFKRnvfJ7a8MFnl5Mi19NneScktqpee7tGs7uZruAYmmJh/xm/Hp1Y0YOt/MYN4WAasCVh+n4+Exb0C+5tD7ck+W387440Tmpi1CkuMctB7uHjuUpbOLWh5UYOvQ76//6tWPGZu4/KkY7TXUzshzVvWqOXAk/5NZ45ysZcBn/Qy8Bd4kqrF3vXoHRIEXkZkGky8mcjraRBBUVQUuCgZVIEjgTemsy4ip1OjPN9RCANl8nhyJAMDLArF89dHuzWY50= stetsed@ArchHome" | sudo tee -a /etc/dropbear/root_key

	echo " ip=dhcp" | sudo tee -a /etc/kernel/cmdline

	sudo sed -i 's/zfs/netconf dropbear zfsencryptssh zfs/g' /etc/mkinitcpio.conf

	echo 'ZFS Remote Unlock Setup Complete'
}

Framework_TLP_Setup() {
	yay -Syu tlp

	echo -e "CPU_SCALING_GOVERNOR_ON_AC=performance\nCPU_SCALING_GOVERNOR_ON_BAT=powersave\nCPU_ENERGY_PERF_POLICY_ON_AC=performance\nCPU_ENERGY_PERF_POLICY_ON_BAT=balance_power\nCPU_HWP_DYN_BOOST_ON_AC=1\nCPU_HWP_DYN_BOOST_ON_BAT=1" | sudo tee /etc/tlp.d/01-basic.conf

	sduo systemctl enable tlp.service

	echo "Framework TLP Power Tuning Setup Complete"
}

Framework_80_100_Setup() {
	echo -e "[Unit]\nDescription=Framework Battery Script\n\n[Service]\nExecStart=/home/stetsed/.bin/scripts/framework-battery.sh\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/framework-battery.service

	echo -e "[Unit]\nDescription=Run My Service Every 5 Minutes\n\n[Timer]\nOnCalendar=*:0/5\nUnit=framework-battery.service\n\n[Install]\nWantedBy=timers.target" | sudo tee /etc/systemd/system/framework-battery.timer

	sudo systemctl enable framework-battery.timer

	echo "Framework 80-100 Battery Script Setup Complete"
}

Framework_Fingerprint_Setup() {
	yay -S fprintd

	echo -e "#%PAM-1.0\nauth        sufficient      pam_fprintd.so\n\nauth\tinclude\t\tsystem-auth\naccount\tinclude\t\tsystem-auth\nsession\tinclude\t\tsystem-auth" | sudo tee /etc/pam.d/sudo

	echo -e "#\n# PAM configuration file for the swaylock screen locker. By default, it includes\n# the 'login' configuration file (see /etc/pam.d/login)\n#\n\nauth\t\tsufficient\t\tpam_unix.so try_first_pass likeauth nullok\nauth\t\tsufficient\t\tpam_fprintd.so\n\nauth include login" | sudo tee /etc/pam.d/swaylock

	echo -e "#%PAM-1.0\n\nauth\t\tsufficient\t\tpam_unix.so try_first_pass likeauth nullok\n\nauth\t\tinclude\t\tsystem-auth\naccount\t\tinclude\t\tsystem-auth\npassword\t\tinclude\t\tsystem-auth\nsession\t\tinclude\t\tsystem-auth" | sudo tee /etc/pam.d/polkit-1

	echo -e "#%PAM-1.0\n\nauth\t\tsufficient\t\tpam_unix.so try_first_pass likeauth nullok\n\nauth\t\tinclude\t\t\t\t\t\t\t\tsystem-login\naccount\t\tinclude\t\t\t\t\t\t\tsystem-login\npassword\tinclude\t\t\t\t\t\t\tsystem-login\nsession\t\tinclude\t\t\t\t\t\t\tsystem-login" | sudo tee /etc/pam.d/system-local-login

	echo "Framework Fingerprint Setup Complete"
}

Main_Run() {
	# check if gum is installed
	if ! command -v gum &>/dev/null; then
		echo "Gum is not installed, installing gum"
		pacman-key --init
		sudo pacman -Sy gum
		sleep 5
	fi

	clear
	echo "What part of the installation are you on"
	ZFS="ZFS"
	CHROOT="Chroot"
	USER="User"
	FILE_TRANSFER="File Transfer"
	SERVER_SHELL="Server Shell"
	EXTRA="Extra"
	SELECTION=$(gum choose --cursor-prefix "[ ] " --selected-prefix "[✓] " "$ZFS" "$CHROOT" "$USER" "$FILE_TRANSFER" "$SERVER_SHELL" "$EXTRA")
	grep -q "$ZFS" <<<"$SELECTION" && ZFS_Run
	grep -q "$CHROOT" <<<"$SELECTION" && Chroot_Run
	grep -q "$USER" <<<"$SELECTION" && User_Run
	grep -q "$FILE_TRANSFER" <<<"$SELECTION" && File_Run
	grep -q "$SERVER_SHELL" <<<"$SELECTION" && Server_Setup
	grep -q "$EXTRA" <<<"$SELECTION" && Extra_Run

}

Main_Run
