#!/bin/zsh
# shellcheck shell=bash

# Turn off the Citrix Workspace Helper Tool

# kill the various processes
if pgrep "Citrix Workspace"; then
    pkill "Citrix Workspace"
fi

if pgrep "AuthManager_Mac"; then
    pkill "AuthManager_Mac"
fi

# current logged-in user's short name
current_user=$(/bin/ls -la /dev/console | /usr/bin/cut -d " " -f 4)
uid=$(id -u "$current_user")
echo "Current user is $current_user"

# set preference to remove the helper tool
/usr/bin/defaults write "/Users/$current_user/Library/Preferences/com.citrix.receiver.nomas.plist" ShowHelperInMenuBar 0

echo "Written preferences to /Users/$current_user/Library/Preferences/com.citrix.receiver.nomas.plist"