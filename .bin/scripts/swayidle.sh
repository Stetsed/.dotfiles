#!/usr/bin/env bash

swayidle -w \
	timeout 300 'swaylock' \
	before-sleep 'swaylock'
