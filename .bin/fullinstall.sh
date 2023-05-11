#!/usr/bin/env bash

ZFS_Run() {
	clear
	ZFS_Select_Drive

	clear
	ZFS_Get_ZFS

	clear
	ZFS_Partition_Drive

	clear
	ZFS_Setup_Filesystem

	clear
	ZFS_Setup_Basesystem
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

	zpool create -f -O canmount=off -o ashift=12 zroot /dev/disk/by-id/$SELECTED_DRIVE-part2
	zfs create -o canmount=off -o mountpoint=none zroot/ROOT
	zfs create -o canmount=noauto -o mountpoint=/ zroot/ROOT/default
	zfs set compression=on zroot
	zfs set atime=off zroot
	zfs set xattr=sa zroot
	zfs set acltype=posixacl zroot

	zfs create -o mountpoint=none zroot/data
	zfs create -o mountpoint=/home zroot/data/home

	zfs umount -a
	zpool export zroot

	zpool import -d /dev/disk/by-id -R /mnt zroot

	zfs mount zroot/ROOT/default
	zfs mount zroot/data/home
	zpool set bootfs=zroot/ROOT/default zroot

	mkdir /mnt/boot
	mount /dev/disk/by-id/$SELECTED_DRIVE-part1 /mnt/boot
	mkdir /mnt/etc

	return
}

ZFS_Setup_Basesystem() {

  echo -n 'Do you use AMD or INTEL(ex: intel/amd): '
  read cpu

	genfstab -U /mnt >>/mnt/etc/fstab

	pacstrap /mnt base base-devel linux linux-firmware neovim networkmanager $cpu-ucode

	cp fullinstall.sh /mnt/fullinstall.sh

	arch-chroot /mnt

	umount -R /mnt

	zfs umount -a

	zpool export zroot

	reboot
}

Chroot_Run() {
	clear
	Chroot_Setup_ZFS

	clear
	Chroot_Install_Packages

	clear
	Chroot_User

  clear
  Chroot_Setup_UKI 

	clear
	Chroot_Final
}

Chroot_Setup_ZFS() {
	echo -e '[archzfs]\nServer = https://archzfs.com/$repo/$arch' >>/etc/pacman.conf
	pacman-key -r DDF7DB817396A49B2A2723F7403BD972F75D9D76
	pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76
	pacman -Syu
}

Chroot_Install_Packages() {
	pacman -S linux-headers zfs-dkms-git openssh networkmanager fish
}

Chroot_User() {

  echo -n 'Enter Username You Wanna Use: '
  read username

  echo -n 'Enter Password You Wanna Use: '
  read password

	useradd -m -G wheel -s /usr/bin/fish $username
	(
		echo $password
		echo $password
	) | passwd stetsed
}

Chroot_Setup_UKI(){
  echo "zfs=zroot/ROOT/default rw" > /etc/kernel/cmdline

  mkdir -p /boot/EFI/BOOT

  sed -i 's/keyboard keymap/keyboard zfs keymap/g' /etc/mkinitcpio.conf
  sed -i 's/default_image="\/boot\/initramfs-linux.img"/#&\ndefault_uki="\/boot\/EFI\/BOOT\/BOOTX64.EFI"/; s/fallback_image="/#&/' /etc/mkinitcpio.d/linux.preset
}

Chroot_Final() {
  echo "LANG=en_US.UTF-8" >/etc/locale.conf

  echo -n 'What hostname do you wanna use(ex: archlinux): '
  read hostname

  echo $hostname > /etc/hostname
	zpool set cachefile=/etc/zfs/zpool.cache zroot

	systemctl enable NetworkManager

	echo "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers

	systemctl enable zfs-scrub-weekly@zroot.timer
	systemctl enable zfs.target
	systemctl enable zfs-import-cache
	systemctl enable zfs-mount
	zgenhostid $(hostid)

	mkinitcpio -P
}

User_Run() {
	clear
	User_Home

	clear
	User_Yay

	clear
	User_Packages

  echo -n 'Note: This installation expects your dotfiles to be in a bare repository, and expects there to be a .packages.list file in the root of the repository, which has 1 package per line.'
  echo -n 'Enter the Github Repository you wanna use(Ex: Stetsed/.dotfiles):'
  read repository

	clear
	User_Dotfiles

	clear
	User_Extra

  echo -n 'Are you Stetsed and do you wanna use Stetsed Specific Configuration for Storage(ex: yes): '
  read stetsed
  if [[ $stetsed == "yes" ]]; then
    User_Stetsed
  fi

  echo -n 'Program is Finished Executing, have a wonderful day :D'
}

User_Home() {
  username=$(whoami)

	sudo mkdir /home/$username

	sudo chown $username:$username -R /home/$username

	sudo chmod 700 -R /home/$username

	cd /home/$username
}

User_Yay() {
	sudo pacman -Syu git

	git clone https://aur.archlinux.org/paru-bin.git

	cd paru-bin

	makepkg -s

	sudo pacman -U paru-bin*

	cd ..

	rm -rf paru-bin
}


User_Dotfiles() {
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
    cat .packages.list | paru -Syu --needed --noconfirm
  else
    echo "No .packages.list file found. Skipping package installation."
  fi
}

User_Extra() {
	# Enable services
	sudo systemctl enable --now bluetooth
	sudo systemctl enable sddm
	systemctl --user enable --now pipewire
	systemctl --user enable --now pipewire-pulse

  username=$(whoami)

  echo -e "We add an autologin entry for Hyprland, if you do use another please modify /etc/sddm.conf"
	# Add autologin to the sddm.conf and create the group.
	echo -e "[Autologin]\nUser=$username\nSession=hyprland" | sudo tee -a /etc/sddm.conf
	sudo groupadd autologin
	sudo usermod -aG autologin $username

	timedatectl set-ntp true
	timedatectl set-timezone Europe/Amsterdam

}

User_Stetsed() {
	echo "10.4.78.251:/mnt/Vault/Storage /mnt/data nfs defaults,_netdev,x-systemd.automount,x-systemd.mount-timeout=10,noauto 0 0" | sudo tee -a /etc/fstab
	sudo mkdir /mnt/data

	ln -s /mnt/data/Stetsed/Storage ~/Storage
	ln -s /mnt/data/Stetsed/Documents ~/Documents
	mkdir Downloads


}

File_Run() {
	clear
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

	cp -r ~/.librewolf ~/Storage/Transfer/

	rm -rf ~/.config/WebCord/Cache/

	cp -r ~/.config/WebCord ~/Storage/Transfer/

	cp -r ~/.ssh ~/Storage/Transfer/

	exit
}

File_From() {
	pkill librewolf
	pkill webcord

	rm -rf ~/.librewolf
	cp -r ~/Storage/Transfer/.librewolf ~/

	rm -rf ~/.config/WebCord
	cp -r ~/Storage/Transfer/WebCord ~/.config/

	rm -rf ~/.ssh
	cp -r ~/Storage/Transfer/.ssh ~/
}

Server_Setup(){
  source /etc/os-release

  if [[ $ID == "debian" ]]; then
    Server_Setup_Debian
  elif [[ $ID == "arch" ]]; then
    Server_Setup_Arch
  else
    echo "Unsupported operating system: $ID"
  fi
}

Server_Setup_Arch(){
  sudo pacman -Syu kitty fish starship
  sudo chsh -s /usr/bin/fish
  echo "Please exit this terminal with the exit command, this is to generate the fish start config"
  fish
  echo "starship init fish | source" >> ~/.config/fish/config.fish

  mkdir -p ~/.config/fish/functions
  curl -sL https://raw.githubusercontent.com/Stetsed/.dotfiles/main/.config/fish/functions/nano.fish > ~/.config/fish/functions/nano.fish
}

Server_Setup_Debian(){
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  ln -s ~/.local/kitty.app/bin/kitty /bin/kitty
  ln -s ~/.local/kitty.app/bin/kitten /bin/kitten

  sudo chsh -s /usr/bin/fish

  curl -sS https://starship.rs/install.sh | sh

  echo "Please exit this terminal with the exit command, this is to generate the fish start config"
  fish
  echo "starship init fish | source" >> ~/.config/fish/config.fish

  mkdir -p ~/.config/fish/functions
  curl -sL https://raw.githubusercontent.com/Stetsed/.dotfiles/main/.config/fish/functions/nano.fish > ~/.config/fish/functions/nano.fish
}
)

Main_Run() {
	sudo pacman -Sy gum

	clear

	echo "What part of the installation are you on"
	ZFS="ZFS"
	CHROOT="Chroot"
	USER="User"
	FILE_TRANSFER="File Transfer"
  SERVER_SHELL="Server Shell"
	SELECTION=$(gum choose --cursor-prefix "[ ] " --selected-prefix "[✓] " "$ZFS" "$CHROOT" "$USER" "$FILE_TRANSFER" "$SERVER_SHELL")
	grep -q "$ZFS" <<<"$SELECTION" && ZFS_Run
	grep -q "$CHROOT" <<<"$SELECTION" && Chroot_Run
	grep -q "$USER" <<<"$SELECTION" && User_Run
	grep -q "$FILE_TRANSFER" <<<"$SELECTION" && File_Run
  grep -q "$SERVER_SHELL" <<<"$SELECTION" && Server_Setup

}

Main_Run
