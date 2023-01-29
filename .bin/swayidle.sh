#!/bin/sh

swayidle -w \
        timeout 300 'swaylock' \
        timeout 400 'hyprctl dispatch dpms off' \
                resume 'hyprctl dispatch dpms on' \
        before-sleep 'swaylock'
