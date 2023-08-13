#!/bin/bash

# Script designed to run on a netbox export file and then export the ones which will be added to the static mappings.

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <csv file>"
	exit 1
fi

# Input CSV file
csv_file=$1

# Read the CSV file line by line
while IFS=',' read -r ip vrf status role tenant assigned dns_name description rest; do
	# Skip the header row
	if [ "$ip" != "IP Address" ]; then
		# Extract the first octet of the IP address
		first_octet=$(echo "$ip" | cut -d. -f1)

		# Check if the first octet is 10
		if [ "$first_octet" = "10" ]; then
			name="${dns_name%%.*}"
			ip_without_mask=$(echo "$ip" | cut -d/ -f1)
			echo "set service dhcp-server shared-network-name LAN-main-network subnet 10.0.0.0/8 static-mapping $name mac-address $description"
			echo "set service dhcp-server shared-network-name LAN-main-network subnet 10.0.0.0/8 static-mapping $name ip-address $ip_without_mask"
			echo "set system static-host-mapping host-name $dns_name inet $ip_without_mask"
		fi
	fi
done <"$csv_file"
