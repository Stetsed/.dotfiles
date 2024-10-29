#!/usr/bin/env bash
sleep 1
killall xdg-desktop-portal-hyprland
killall xdg-desktop-portal-wlr
killall xdg-desktop-portal
/usr/libexec/xdg-desktop-portal-hyprland &
sleep 2
/usr/lib/xdg-desktop-portal &

sleep 1

if [[ -f "/home/$(whoami)/.enable-ags" ]]; then
	ags &
else
	waybar -c ~/.config/waybar/config.jsonc &
	dunst &
	swayosd-server &
fi
