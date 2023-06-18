#!/bin/bash

User_Run() {

	User_Home

	User_Paru

	User_Dotfiles

	echo "Your dotfiles have been installed with Yadm, I have recently removed the bootstrap options from this script and moved it to yadm bootstrap so if you wish to see those check the repository."

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
	sudo pacman -S reflector

	sudo systemctl start reflector

	sudo pacman -Syu git

	git clone https://aur.archlinux.org/paru-bin.git

	cd paru-bin

	makepkg -s

	sudo pacman -U paru-bin*

	cd ..

	rm -rf paru-bin

	echo -e "[options]\nCacheDir = /var/lib/repo/aur\n\n[aur]\nSigLevel = PackageOptional DatabaseOptional\nServer = file:///var/lib/repo/aur" | sudo tee -a /etc/pacman.conf

}

User_Dotfiles() {
	echo 'Note: This installation expects your dotfiles to be in a bare repository.'
	echo 'Enter the Github Repository you wanna use: '
	repository=$(gum input --placeholder "stetsed/.dotfiles")

	pacman -Syu yadm

	yadm clone https://github.com/$repository.git
}

User_Run
