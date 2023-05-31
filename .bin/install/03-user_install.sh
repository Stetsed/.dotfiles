#!/bin/bash

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

User_Run
