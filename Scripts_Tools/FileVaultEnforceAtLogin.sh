#!/bin/sh

## Check that the current user is enabled for FileVault (Secure Token), and
## enable FileVault if so, or inform that the user must be enabled first.

user_has_secure_token=0
filevault_is_enabled=0

filevault_defer_file_location="/Library/Application Support/JAMF/run/file_vault_2_recovery_key.xml"

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

filevault_icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FileVaultIcon.icns"

jamf_helper() {
    # inputs
    # $1 - window type (hud / fs )
    # $2 - title
    # $3 - heading
    # $4 - description
    # $5 - icon

    if [[ -f "${jamfHelper}" ]]; then
        "${jamfHelper}" -windowType $1 -title "$2" -alignHeading left -heading "$3" -alignDescription left -description "$4" -button1 "OK" -defaultButton 1 -icon "$filevault_icon"
    fi

}

# get current user
loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

# get filevault status
[[ $(/usr/bin/fdesetup status) == "FileVault is On." ]] && filevault_is_enabled=1

# check if current user has secure token
/usr/bin/fdesetup list | /usr/bin/grep $loggedInUser && user_has_secure_token=1

enabled_users=""

while read line ; do
    enabled_users+="$(echo $line | cut -d, -f1)"
done <<< "$(/usr/bin/fdesetup list)"

[[ $enabled_users == "" ]] && enabled_users="None"

if [[ $filevault_is_enabled = 0 && $user_has_secure_token = 0 ]]; then
    jamf_helper utility "FileVault Policy" "User has no Secure Token" "This computer cannot be enabled for FileVault by a user without a Secure Token. Please login as one of the following users and try again: ${enabled_users}"
    exit
elif [[ $filevault_is_enabled = 0 && $user_has_secure_token = 1 ]]; then
    jamf_helper utility "FileVault Policy" "User has Secure Token" "This computer will be encrypted with FileVault at the next login of user $loggedInUser."
    /usr/bin/fdesetup enable -defer "$filevault_defer_file_location" -forceatlogin 0 -dontaskatlogout
else
    echo "FileVault is already enabled on this device."
fi
