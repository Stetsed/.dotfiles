#!/bin/bash

switch_to_bluesky ()
{
  cp ~/.config/alacritty/bluesky.alacritty.yml ~/.config/alacritty/alacritty.yml
  sed -i "s|exec = swaybg.*|exec = swaybg -m fill -i ~/.bin/bluesky_wallpaper.png|g" ~/.config/hypr/hyprland.conf
}

switch_to_darknight ()
{
  cp ~/.config/alacritty/darknight.alacritty.yml ~/.config/alacritty/alacritty.yml
  sed -i "s|exec = swaybg.*|exec = swaybg -m fill -i ~/.bin/darknight_wallpaper.png|g" ~/.config/hypr/hyprland.conf
}

if grep -q "0x010002" ~/.config/alacritty/alacritty.yml; then
    switch_to_bluesky
elif grep -q "0x0e1c2f" ~/.config/alacritty/alacritty.yml ; then
    switch_to_darknight
else
   notify-send "Irregular Pattern Detected, Failed to switch" 
fi
