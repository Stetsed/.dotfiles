#!/bin/bash

selection=$1

result=$(echo $(swww query) | grep -o 'image: "[^"]*"')
result=${result#image: \"}
result=${result%\"}
current_wallpaper=${result%\"}

if [ "$selection" = "change" ]; then
	if [ "$current_wallpaper" = "catppuccin_wallpaper.png" ]; then
		new_wallpaper="Estradiol_non_bin.png"
		swww img ~/.bin/backgrounds/pngs/$new_wallpaper --transition-type center
	elif [ "$current_wallpaper" = "Estradiol_non_bin.png" ]; then
		new_wallpaper="Estradiol_trans.png"
		swww img ~/.bin/backgrounds/pngs/$new_wallpaper --transition-type center
	elif [ "$current_wallpaper" = "Estradiol_trans.png" ]; then
		new_wallpaper="catppuccin_wallpaper.png"
		swww img ~/.bin/backgrounds/pngs/$new_wallpaper --transition-type center
	fi
else
	new_wallpaper="Estradiol_trans.png"
	swww img ~/.bin/backgrounds/pngs/$new_wallpaper --transition-step 255
fi
