#!/usr/bin/env bash

swayidle -w \
	timeout 300 '~/.bin/scripts/lock.sh' \
	before-sleep '~/.bin/scripts/lock.sh'
