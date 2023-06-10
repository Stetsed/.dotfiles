#!/usr/bin/bash

if [[ "$1" == "--close" ]]; then
	eww close bluetooth-menu
else
	eww open bluetooth-menu
fi
