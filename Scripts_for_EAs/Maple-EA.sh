#!/bin/bash

# Maple license detector

management_dir="/Library/Management/ETHZ/Maple"
node_license_store="$management_dir/.Node.license"
floating_license_store="$management_dir/.Floating.license"

active_license="/Library/Frameworks/Maple.framework/Versions/Current/license/license.dat"

if [[ -f "$active_license" ]]; then
	if cmp -s "$active_license" "$node_license_store"; then
		license_type="Node"	
	elif cmp -s "$active_license" "$floating_license_store"; then
		license_type="Floating"
	else
		license_type="Invalid"
	fi
else
	license_type="None"
fi

echo "<result>$license_type</result>"