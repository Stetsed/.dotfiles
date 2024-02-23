#!/bin/bash

if [[ $1 == "off" ]]; then
	hyprctl dispatch dpms off
else
	hyprctl dispatch dpms on
fi
