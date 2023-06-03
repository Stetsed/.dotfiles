#!/bin/bash

hostname=$(hostname)

if [[ $hostname == *"Desktop"* ]]; then
  exit 0
fi

if [[ $1 == "off" ]]; then 
    hyprctl dispatch dpms off
else
    hyprctl dispatch dpms on
fi
