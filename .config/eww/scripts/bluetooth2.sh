#!/bin/bash

get_bluetoothinfo() {
	bluetooth_devices=$(jc -p bluetoothctl devices)
	# Make a list of the adresses of the devices in an array
	adresses=$(echo "$bluetooth_devices" | jq -r '.[].address')

	# Run each of the devices in the array through the jc info (adress) and compile it into a single json.
	device_info=$(for adress in $adresses; do echo "$bluetooth_devices" | jc bluetoothctl info "$adress"; done | jq -s add)

	# Parse the json to json and get the name, if it's paired, and if it's connected.
	info1=$(echo "$device_info" | jq -r '.[] | {name: .name,address: .address, paired: .paired, connected: .connected}')

	# if paired is empty set it to false, if connected is empty set it to false
	info2=$(echo "$device_info" | jq -r '.[] | {name: .name,address: .address, paired: .paired, connected: .connected} | .paired |= if . == "" then false else . end | .connected |= if . == "" then false else . end')

	# Replace all instances of no with false and yes with true
	final1=$(echo "$info2" | sed 's/"no"/false/g' | sed 's/"yes"/true/g')

	final2="[$final1]"

	final3=$(echo $final2 | sed 's/} {/}, {/g')

	echo "$final3"
}

if [[ $1 == "tick" ]]; then
	get_bluetoothinfo
	exit 0
elif [[ $1 == "scan" ]]; then
	bluetoothctl scan on &
	sleep 10
	PID=$!
	kill $PID
	exit 0
elif [[ $1 == "pair" ]]; then
	bluetoothctl pair $2
	exit 0
elif [[ $1 == "unpair" ]]; then
	bluetoothctl remove $2
	exit 0
elif [[ $1 == "connect" ]]; then
	bluetoothctl connect $2
	exit 0
elif [[ $1 == "disconnect" ]]; then
	bluetoothctl disconnect $2
	exit 0
elif [[ $1 == "toggle" ]]; then
	blocked=$(rfkill -J | jq -r '.rfkilldevices[] | select(.type == "bluetooth") | .soft' | head -1)
	if [[ $blocked == "unblocked" ]]; then
		rfkill block bluetooth
	else
		rfkill unblock bluetooth
	fi
	exit 0
elif [[ $1 == "powered" ]]; then
	while true; do
		powered=$(bluetoothctl show | rg Powered | cut -f 2- -d ' ')
		if [[ $powered == "yes" ]]; then
			eww update bluetooth_powered=true
		else
			eww update bluetooth_powered=false
		fi
		sleep 4
	done
else
	while true; do
		get_bluetoothinfo
		sleep 4
	done
fi
