#!/usr/bin/env bash

swayidle -w \
	timeout 300 '~/.bin/scripts/lock.sh' \
	timeout 600 'systemctl suspend' \
	before-sleep '~/.bin/scripts/lock.sh'
