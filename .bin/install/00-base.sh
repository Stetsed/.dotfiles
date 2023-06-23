#!/usr/bin/env bash

Main_Run() {
	sudo pacman-key --init

	sudo pacman -Sy archlinux-keyring

	# check if gum is installed
	if ! command -v gum &>/dev/null; then
		echo "Gum is not installed, installing gum"
		sudo pacman -Sy gum
		sleep 5
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
