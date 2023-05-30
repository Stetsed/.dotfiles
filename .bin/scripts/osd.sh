#!/bin/bash

increase() {
	eww update osd_vol_timer=2
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
	eww update osd_tick=true
}

decrease() {
	eww update osd_vol_timer=2
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
	eww update osd_tick=true
}

toggle() {
	wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
	eww update osd_vol_timer=2
	eww update osd_tick=true
}

brighter() {
	brightnessctl set +5%
	eww update osd_bright_timer=2
	eww update osd_tick=true
}

dimmer() {
	brightnessctl set 5%-
	eww update osd_bright_timer=2
	eww update osd_tick=true
}

tick() {
	eww open osd

	while true; do
		sleep 2
		tick=$(eww get osd_tick)
		if [[ $tick == "true" ]]; then
			timer=$(eww get osd_vol_timer)
			if [[ $timer > 0 ]]; then
				eww update osd_vol_timer=$((timer - 1))
			fi
			timer2=$(eww get osd_bright_timer)
			if [[ $timer2 > 0 ]]; then
				eww update osd_bright_timer=$((timer2 - 1))
			fi
			if [[ $timer == 0 && $timer2 == 0 ]]; then
				eww update osd_tick=false
			fi
		fi

	done
}

case $1 in
"increase")
	increase
	;;
"decrease")
	decrease
	;;
"toggle")
	toggle
	;;
"tick")
	tick
	;;
"bright")
	brighter
	;;
"dimmer")
	dimmer
	;;
esac
