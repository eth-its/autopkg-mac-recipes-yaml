#!/bin/bash

#
# This script will read the identity preference for the lan adapter
# and create a user level identity preference linked to the
# same certificate fund in the system level identity preference.
#
# Note: This only works based on the asumption that Jamf Pro keeps
# the system level identity preference updated accordingly!
#
# Source: https://macadmins.slack.com/archives/C826G2XCL/p1671023029867429?thread_ts=1670967228.762929&cid=C826G2XCL

#
# Prerequisites
#

# Grab the profile id
profileid=$(security find-generic-password -l "Network" | awk -F '"' '/com.apple.network.eap.system.item.profileid/{print $4}' | awk -F '.' '{print $NF}')

# Grab hash - macOS 10.14 and earlier use SHA-1 hashes
osVersion=$(sw_vers -productVersion)
if [[ "$osVersion" =~ ^10.11.* ]] || [[ "$osVersion" =~ ^10.12.* ]] || [[ "$osVersion" =~ ^10.13.* ]] || [[ "$osVersion" =~ ^10.14.* ]]; then
	# Use SHA-1
	hash=$(security get-identity-preference -Z -s "com.apple.network.eap.system.identity.profileid.$profileid" | awk '/SHA-1/{print $NF}')
else
	# Use SHA-256
	hash=$(security get-identity-preference -Z -s "com.apple.network.eap.system.identity.profileid.$profileid" | awk '/SHA-256/{print $NF}')
fi

# Exit if no hash is found
if [[ "$hash" == "" ]]; then
	echo "No certificate found matching user name. Exiting..."
	exit 1
fi


#
# Action
#

# com.apple.network.eap.user.identity.profileid.$profileid must exist in the System keychain
# Use root and default-keychain to access the System keychain
su root -c "security default-keychain -d user -s /Library/Keychains/System.keychain"

# Clear existing identity preference
su root -c "security set-identity-preference -n -s 'com.apple.network.eap.user.identity.profileid.$profileid'"

# Set identity preference
su root -c "security set-identity-preference -Z '$hash' -s 'com.apple.network.eap.user.identity.profileid.$profileid'"

exit 0