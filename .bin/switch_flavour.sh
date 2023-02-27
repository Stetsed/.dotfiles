#!/bin/bash

switch_to_bluesky ()
{
  cp ~/.config/alacritty/bluesky.alacritty.yml ~/.config/alacritty/alacritty.yml
  sed -i "s|exec = swaybg.*|exec = swaybg -m fill -i ~/.bin/bluesky_wallpaper.png|g" ~/.config/hypr/hyprland.conf
  sed -i "s|image=.*|image=~/.bin/bluesky_wallpaper.png|g" ~/.config/swaylock/config
}

switch_to_darknight ()
{
  cp ~/.config/alacritty/darknight.alacritty.yml ~/.config/alacritty/alacritty.yml
  sed -i "s|exec = swaybg.*|exec = swaybg -m fill -i ~/.bin/darknight_wallpaper.png|g" ~/.config/hypr/hyprland.conf
  sed -i "s|image=.*|image=~/.bin/darknight_wallpaper.png|g" ~/.config/swaylock/config
}

CHOICE=$(printf "Bluesky\nDarknight" | rofi -dmenu)

if [ "$CHOICE" = "Bluesky" ]; then
    switch_to_bluesky
    notify-send "Switched to BlueSky"
elif [ "$CHOICE" =  "Darknight" ]; then
    switch_to_darknight
    notify-send "Switched to Darknight"
else
   notify-send "Irregular Pattern Detected, Failed to switch" 
fi
