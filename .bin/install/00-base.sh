#!/usr/bin/env bash

Main_Run() {
	source /etc/os-release

	if [[ $ID == "debian" ]]; then
		# check if gum is installed
		if ! command -v gum &>/dev/null; then
			echo "Gum is not installed, installing gum"
			sudo apt install curl gpg
			sudo mkdir -p /etc/apt/keyrings
			curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
			echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
			sudo apt update && sudo apt install gum
			sleep 5
		fi
	elif [[ $ID == "arch" ]]; then
		sudo pacman-key --init

		sudo pacman -Sy archlinux-keyring

		# check if gum is installed
		if ! command -v gum &>/dev/null; then
			echo "Gum is not installed, installing gum"
			sudo pacman -Sy gum
			sleep 5
		fi
	else
		echo "This script is only for debian or arch based distros"
		exit 1
	fi

	clear
	echo "What part of the installation are you on"
	ZFS="ZFS"
	CHROOT="Chroot"
	USER="User"
	EXTRA="Extra"
	BACKUP="Restore from Backup"
	SELECTION=$(gum choose --cursor-prefix "[ ] " --selected-prefix "[✓] " "$ZFS" "$CHROOT" "$USER" "$EXTRA" "$BACKUP")
	grep -q "$ZFS" <<<"$SELECTION" && bash -c "$(curl -Ls https://raw.githubusercontent.com/stetsed/.dotfiles/main/.bin/install/01-zfs_install.sh)"
	grep -q "$CHROOT" <<<"$SELECTION" && bash -c "$(curl -Ls https://raw.githubusercontent.com/stetsed/.dotfiles/main/.bin/install/02-chroot_install.sh)"
	grep -q "$USER" <<<"$SELECTION" && bash -c "$(curl -Ls https://raw.githubusercontent.com/stetsed/.dotfiles/main/.bin/install/03-user_install.sh)"
	grep -q "$EXTRA" <<<"$SELECTION" && bash -c "$(curl -Ls https://raw.githubusercontent.com/stetsed/.dotfiles/main/.bin/install/04-extra.sh)"
	grep -q "$BACKUP" <<<"$SELECTION" && bash -c "$(curl -Ls https://raw.githubusercontent.com/stetsed/.dotfiles/main/.bin/install/05-restore.sh)"

}

Main_Run
