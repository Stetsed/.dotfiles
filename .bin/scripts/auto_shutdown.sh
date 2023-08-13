#!/bin/bash

# Function to check for active SSH connections
check_ssh_connections() {
	active_connections=$(who | grep -i pts | wc -l)
	if [ "$active_connections" -eq 0 ]; then
		return 0
	else
		return 1
	fi
}

# Function to check CPU usage
check_cpu_usage() {
	cpu_usage=$(top -bn 1 | grep "Cpu(s)" | awk '{print $2}' | cut -d '.' -f 1)
	if [ "$cpu_usage" -lt 10 ]; then
		return 0
	else
		return 1
	fi
}

# Check if the current time is between 00:00 and 04:00
current_hour=$(date +"%H")
if [ "$current_hour" -ge 0 ] && [ "$current_hour" -lt 4 ]; then
	# Check conditions and shut down if they are met
	if check_ssh_connections && check_cpu_usage; then
		echo "Shutting down the system..."
		# Uncomment the line below to actually shut down the system
		# shutdown -h now
	else
		echo "Conditions not met. System will not be shut down."
	fi
else
	echo "Current time is not between 00:00 and 04:00. System will not be shut down."
fi
