#!/bin/zsh

# This script will remove a LaunchDaemon that watches the Jamf log for changes and launches swiftDialog if anything is getting installed

# Location of swiftDialog progress script
progress_script_location="${4}"   # jamf parameter 4
if [[ -z "$progress_script_location" ]]; then
    progress_script_location="/Library/Management/ETHZ/PolicyProgressDialogs"
fi

lock_file="/var/tmp/lock.txt"

# Stop the current launchagent and remove it prior to installing this updated one
ld_label="com.github.grahampugh.swiftDialogLauncher"
launchdaemon="/Library/LaunchDaemons/$ld_label.plist"

if [[ -f "$launchdaemon" ]]; then
    /bin/launchctl unload -F "$launchdaemon"
    /bin/rm "$launchdaemon"
fi

# remove the lock file in case it got stuck on a policy that didn't end (also useful while testing)
if [[ -f "$lock_file" ]]; then
    /bin/rm -f "$lock_file"
fi

sleep 2

# remove launcher scripy 
rm "$progress_script_location/swiftDialogLauncher.zsh"
