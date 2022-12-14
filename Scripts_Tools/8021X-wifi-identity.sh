#!/bin/bash

#
# This script will read the identity preference for the provided WiFi
# name and create a user level identity preference linked to the
# same certificate found in the system level identity preference.
#
# Note: This only works based on the asumption that Jamf Pro keeps
# the system level identity preference updated accordingly!
#
# Source: https://macadmins.slack.com/archives/C826G2XCL/p1671022752569959?thread_ts=1670967228.762929&cid=C826G2XCL

#
# Prerequisites
#

# Parameter Check
if [[ "$4" != "" ]]; then
	wifi="$4"
else
	echo "No WiFi Name provided. Exiting..."
	exit 1
fi

# Grab hash - macOS 10.14 and earlier use SHA-1 hashes
osVersion=$(sw_vers -productVersion)
if [[ "$osVersion" =~ ^10.11.* ]] || [[ "$osVersion" =~ ^10.12.* ]] || [[ "$osVersion" =~ ^10.13.* ]] || [[ "$osVersion" =~ ^10.14.* ]]; then
	# Use SHA-1
	hash=$(security get-identity-preference -Z -s "com.apple.network.eap.system.identity.wlan.ssid.$wifi" | awk '/SHA-1/{print $NF}')
else
	# Use SHA-256
	hash=$(security get-identity-preference -Z -s "com.apple.network.eap.system.identity.wlan.ssid.$wifi" | awk '/SHA-256/{print $NF}')
fi

# Exit if no hash is found
if [[ "$hash" == "" ]]; then
	echo "No certificate found matching user name. Exiting..."
	exit 1
fi

# Grab username from Wifi System object / If you also need a username password object. 
username=$(security find-generic-password  -s 'com.apple.network.eap.system.item.wlan.ssid.$wifi' | awk -F "\"" '/acct/ {print $4}')

# Exit if no wifi username is found
if [[ "$username" == "" ]]; then
	echo "No wifi username found. Exiting..."
	exit 1
fi


#
# Action
#

# com.apple.network.eap.user.identity.wlan.ssid.$wifi must exist in the System keychain
# Use root and default-keychain to access the System keychain
su root -c "security default-keychain -d user -s /Library/Keychains/System.keychain"

# Clear existing identity preference
su root -c "security set-identity-preference -n -s 'com.apple.network.eap.user.identity.wlan.ssid.$wifi'"
su root -c "security delete-generic-password -s 'com.apple.network.eap.user.item.wlan.ssid.$wifi'"

# Set identity preference
su root -c "security set-identity-preference -Z '$hash' -s 'com.apple.network.eap.user.identity.wlan.ssid.$wifi'"

# Only needed if you also need password object
su root -c "security add-generic-password -A -a '$username' -D '802.1X Password' -l '$wifi' -s 'com.apple.network.eap.user.item.wlan.ssid.$wifi'"

exit 0