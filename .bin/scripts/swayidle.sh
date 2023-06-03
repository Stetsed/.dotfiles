#!/usr/bin/env bash

swayidle -w \
	timeout 300 '~/.bin/scripts/lock.sh' \
	timeout 350 '~/.bin/scripts/dpms.sh off' \
	resume '~/.bin/scripts/dpms.sh on' \
	before-sleep '~/.bin/scripts/lock.sh'
