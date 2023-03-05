#!/usr/bin/env bash

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

switch_to_catppuccin ()
{
  cp ~/.config/alacritty/catppuccin.alacritty.yml ~/.config/alacritty/alacritty.yml
  sed -i "s|exec = swaybg.*|exec = swaybg -m fill -i ~/.bin/catppuccin_wallpaper.png|g" ~/.config/hypr/hyprland.conf
  sed -i "s|image=.*|image=~/.bin/catppuccin_wallpaper.png|g" ~/.config/swaylock/config
}

CHOICE=$(printf "Bluesky\nDarknight\nCatppuccin" | rofi -dmenu)

if [ "$CHOICE" = "Bluesky" ]; then
    switch_to_bluesky
    notify-send "Switched to BlueSky"
elif [ "$CHOICE" =  "Darknight" ]; then
    switch_to_darknight
    notify-send "Switched to Darknight"
elif [ "$CHOICE" =  "Catppuccin" ]; then
    switch_to_catppuccin
    notify-send "Switched to Catppuccin"
else
   notify-send "Irregular Pattern Detected, Failed to switch" 
fi
