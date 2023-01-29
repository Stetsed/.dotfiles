#!/bin/bash

# options do be displayed
option0="two %"
option1="twenty %"
option2="forty %"
option3="sixty %"
option4="eighty %"
option5="hundred %"

# options passed to variable
options="$option0\n$option1\n$option2\n$option3\n$option4\n$option5"

selected="$(echo -e "$options" | rofi -lines 5 -dmenu -p "brightness")"
case $selected in
    $option0)
		sudo bash -c "echo 1920 > /sys/class/backlight/intel_backlight/brightness";;
    $option1)
        sudo bash -c "echo 19200 > /sys/class/backlight/intel_backlight/brightness";;
    $option2)
        sudo bash -c "echo 38400 > /sys/class/backlight/intel_backlight/brightness";;
	$option3)
        sudo bash -c "echo 57600 > /sys/class/backlight/intel_backlight/brightness";;
	$option4)
        sudo bash -c "echo 76800 > /sys/class/backlight/intel_backlight/brightness";;
	$option5)
        sudo bash -c "echo 96000 > /sys/class/backlight/intel_backlight/brightness";;
esac
