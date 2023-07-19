#!/bin/bash
echo "Are you Stetsed?"
is_stetsed=$(gum choose "Yes" "No")

if [ "$is_stetsed" == "Yes" ]; then
	echo "10.4.78.251:/mnt/Vault/Storage /mnt/data nfs defaults,_netdev,x-systemd.automount,x-systemd.mount-timeout=10,noauto 0 0" | sudo tee -a /etc/fstab
	sudo mkdir /mnt/data

	sudo mount -t nfs 10.4.78.251:/Vault/Storage

	mkdir ~/Network
	ln -s /mnt/data/Stetsed/Storage ~/Network/Storage
	ln -s /mnt/data/Stetsed/Documents ~/Network/Documents
	mkdir Downloads

	sudo systemctl mask NetworkManager-wait-online.service

	ln -s /run/media/$(whoami)/ ~/USB

	export GPG_TTY=$(tty)

	gpg --pinetry-mode ask --import ~/Network/Storage/Long-Term

	yadm decrypt
else
	exit 0
fi
