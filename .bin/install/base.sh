#!/usr/bin/env bash

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
	EXTRA="Extra"
	SELECTION=$(gum choose --cursor-prefix "[ ] " --selected-prefix "[✓] " "$ZFS" "$CHROOT" "$USER" "$FILE_TRANSFER" "$EXTRA")
	grep -q "$ZFS" <<<"$SELECTION" && bash -c "$(curl -Ls https://raw.githubusercontent.com/stetsed/.dotfiles/main/.bin/install/zfs_install.sh)"
	grep -q "$CHROOT" <<<"$SELECTION" && bash -c "$(curl -Ls https://raw.githubusercontent.com/stetsed/.dotfiles/main/.bin/install/chroot_install.sh)"
	grep -q "$USER" <<<"$SELECTION" && bash -c "$(curl -Ls https://raw.githubusercontent.com/stetsed/.dotfiles/main/.bin/install/user_install.sh)"
	grep -q "$FILE_TRANSFER" <<<"$SELECTION" && bash -c "$(curl -Ls https://raw.githubusercontent.com/stetsed/.dotfiles/main/.bin/install/transfer.sh)"
	grep -q "$EXTRA" <<<"$SELECTION" && bash -c "$(curl -Ls https://raw.githubusercontent.com/stetsed/.dotfiles/main/.bin/install/extra.sh)"

}

Main_Run
