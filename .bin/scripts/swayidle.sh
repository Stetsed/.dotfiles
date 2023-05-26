#!/usr/bin/env bash

swayidle -w \
	timeout 300 '~/.bin/scripts/lock.sh' \
	timeout 400 'hyprctl dispatch dpms off' \
	resume 'hyprctl dispatch dpms on' \
	before-sleep '~/.bin/scripts/lock.sh'
