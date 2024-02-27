#!/bin/bash

# Enable Bluetooth Service and Pipewire Audio
sudo systemctl enable --now bluetooth
systemctl --user enable --now pipewire
systemctl --user enable --now pipewire-pulse

# Enable OSD service
sudo systemctl enable --now swayosd-libinput-backend.service

# Add autologin for the current user, assumes you will handle login on your WM/DE
username=$(whoami)

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=-/usr/bin/agetty --autologin $username --noclear %I $TERM" | sudo tee /etc/systemd/system/getty@tty1.service.d/skip-prompt.conf
sudo systemctl enable getty@tty1.service

# Setting system timezone
echo 'Please select a timezone to use for the system'
timezone=$(timedatectl list-timezones | gum filter)

sudo systemctl enable --now systemd-timesyncd.service
sudo timedatectl set-ntp true
sudo timedatectl set-timezone $timezone
