#!/bin/bash

#
# This script will read the identity preference for the lan adapter
# and create a user level identity preference linked to the
# same certificate fund in the system level identity preference.
#
# Note: This only works based on the asumption that Jamf Pro keeps
# the system level identity preference updated accordingly!
#

#
# Grab the profile id
#

# first we get all profile IDs
profileid_list=$(plutil -extract Profiles raw /Library/Preferences/SystemConfiguration/com.apple.network.eapolclient.configuration.plist)

# convert to a list
profile_ids=()
while read -r line ; do
    profile_ids+=("$line")
done <<< "$profileid_list"

# figure out which ID is assigned the name "Network" -> this is the LAN profile ID
for id in "${profile_ids[@]}"; do
    UserDefinedName=$(/usr/libexec/PlistBuddy -c "Print :Profiles:$id:UserDefinedName" /Library/Preferences/SystemConfiguration/com.apple.network.eapolclient.configuration.plist)
    if [[ $UserDefinedName == "Network" ]]; then
        echo "LAN profile found"
        lan_profile_id="$id"
        echo " -> $lan_profile_id"
    fi
done

# fail if we didn't find the right one
if [[ ! "$lan_profile_id" ]]; then
    echo "ERROR: Profile ID not found"
    exit 0
fi

#
# Grab hash - macOS 10.14 and earlier use SHA-1 hashes
#

osVersion=$(sw_vers -productVersion)
if [[ "$osVersion" =~ ^10.11.* ]] || [[ "$osVersion" =~ ^10.12.* ]] || [[ "$osVersion" =~ ^10.13.* ]] || [[ "$osVersion" =~ ^10.14.* ]]; then
	# Use SHA-1
	echo "Getting SHA1 hash of the identity preference"
	hash=$(security get-identity-preference -Z -s "com.apple.network.eap.system.identity.profileid.$lan_profile_id" | awk '/SHA-1/{print $NF}')
else
	# Use SHA-256
	echo "Getting SHA256 hash of the identity preference"
	hash=$(security get-identity-preference -Z -s "com.apple.network.eap.system.identity.profileid.$lan_profile_id" | awk '/SHA-256/{print $NF}')
fi

# Exit if no hash is found
if [[ "$hash" == "" ]]; then
	echo "No certificate found matching user name. Exiting..."
	exit 0
fi


#
# Action
#

# com.apple.network.eap.user.identity.profileid.$profileid must exist in the System keychain
# Use root and default-keychain to access the System keychain
echo "Setting default keychain to system for the user"
su root -c "security default-keychain -d user -s /Library/Keychains/System.keychain"

# Clear existing identity preference
echo "Clearing existing identity preference"
su root -c "security set-identity-preference -n -s 'com.apple.network.eap.user.identity.profileid.$lan_profile_id'"

# Set identity preference
echo "Setting new identity preference"
su root -c "security set-identity-preference -Z '$hash' -s 'com.apple.network.eap.user.identity.profileid.$lan_profile_id'"

exit 0
