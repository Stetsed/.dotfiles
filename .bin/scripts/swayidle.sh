#!/usr/bin/env bash

swayidle -w \
	timeout 300 'swaylock' \
	timeout 600 'systemctl suspend' \
	before-sleep 'swaylock'
