#!/bin/bash

#
# This script will read the identity preference for the provided WiFi
# name and create a user level identity preference linked to the
# same certificate found in the system level identity preference.
#
# Note: This only works based on the assumption that Jamf Pro keeps
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
	exit 0
fi

# Grab hash - macOS 10.14 and earlier use SHA-1 hashes
osVersion=$(sw_vers -productVersion)
if [[ "$osVersion" =~ ^10.11.* ]] || [[ "$osVersion" =~ ^10.12.* ]] || [[ "$osVersion" =~ ^10.13.* ]] || [[ "$osVersion" =~ ^10.14.* ]]; then
	# Use SHA-1
	echo "Getting SHA1 hash of the identity preference"
	hash=$(security get-identity-preference -Z -s "com.apple.network.eap.system.identity.wlan.ssid.$wifi" | awk '/SHA-1/{print $NF}')
else
	# Use SHA-256
	echo "Getting SHA256 hash of the identity preference"
	hash=$(security get-identity-preference -Z -s "com.apple.network.eap.system.identity.wlan.ssid.$wifi" | awk '/SHA-256/{print $NF}')
fi

# Exit if no hash is found
if [[ "$hash" == "" ]]; then
	echo "No certificate found matching user name. Exiting..."
	exit 0
fi

#
# Action
#

# com.apple.network.eap.user.identity.wlan.ssid.$wifi must exist in the System keychain
# Use root and default-keychain to access the System keychain
echo "Setting default keychain to system for the user"
su root -c "security default-keychain -d user -s /Library/Keychains/System.keychain"

# Clear existing identity preference
echo "Clearing existing identity preference"
su root -c "security set-identity-preference -n -s 'com.apple.network.eap.user.identity.wlan.ssid.$wifi'"

echo "Clearing existing wifi password"
su root -c "security delete-generic-password -s 'com.apple.network.eap.user.item.wlan.ssid.$wifi'"

# Set identity preference
echo "Setting new identity preference"
su root -c "security set-identity-preference -Z '$hash' -s 'com.apple.network.eap.user.identity.wlan.ssid.$wifi'"

exit 0