#!/bin/bash

echo 'To enable the bluetooth package you require the bluez package installed, and for pipewire you need pipewire and pipewire-pulse installed``'

echo 'Do you wanna install enable bluetooth?'
bluetooth=$(gum choose "Yes" "No")

echo 'Do you want to enable pipewire?'
pipewire=$(gum choose "Yes" "No")

if [[ $bluetooth == "Yes" ]]; then
	sudo systemctl enable --now bluetooth
fi

if [[ $pipewire == "Yes" ]]; then
	systemctl --user enable --now pipewire
	systemctl --user enable --now pipewire-pulse
fi

username=$(whoami)

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin $username --noclear %I $TERM" | sudo tee -a /etc/systemd/system/getty@tty1.service.d/skip-prompt.conf
sudo systemctl enable getty@tty1.service

time=$(gum choose "Yes" "No")

if [[ $time == "Yes" ]]; then
	echo 'When entering timezone please use the following format: Region/City with correct capitalization.'
	timezone=$(gum input --placeholder "Europe/Amsterdam")

	sudo systemctl enable --now systemd-timesyncd.service
	sudo timedatectl set-ntp true
	sudo timedatectl set-timezone $timezone
fi
