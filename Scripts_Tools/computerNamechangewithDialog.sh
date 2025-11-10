#!/bin/bash

# Set Computer Name using an AppleScript dialog
# by Philippe Scholl
# Edited by Graham Pugh 2018-06-25
# Added check for desktop 2018-07-02

#renameHost
###functions

isDesktopReady() {
    c=1
	while [[ ${c} -le 30 ]]; do
        if [[ -f "/Applications/ETH Self Service.app/Contents/MacOS/Self Service" ]] && [[ "${loggedInUser}" != "_mbusersetup" ]] && [[ $( pgrep Finder | wc -l ) -gt 0 ]]; then
	        echo "[$(date)] Desktop is ready, we can continue..."
            break
        elif [[ -f "/Applications/ETH Self Service.app/Content/MacOS/Self Service..." ]]; then
            echo "[$(date)] Desktop not yet ready"
            echo "[$(date)] Current User: ${loggedInUser}"
        else
            echo "[$(date)] Self Service not present so Jamf not ready..."
            echo "[$(date)] Current User: ${loggedInUser}"
        fi
     	let c=${c}+1
        sleep 10
	done
}


machinename() {
    osascript <<'EOT'
        tell application "System Events"
            activate
            set nameentry to text returned of (display dialog "Please Input New Computer Name" default answer "" with icon 2)
            end tell
EOT
}

renameComputer() {
    #Set New Computer Name
    scutil --set ComputerName "${ComputerName}"
    # Remove spaces
    localHostName=$( echo ${ComputerName} | sed -e 's| |-|g' )
    scutil --set LocalHostName "${localHostName}"
    scutil --set HostName "${localHostName}"
	echo "[$(date)] The New Computer name is: ${ComputerName}"
    echo "[$(date)] Rename Successful"
}

### Script
# Check that there is an actively logged in desktop
isDesktopReady
# Go ahead and rename the computer
ComputerName=$(machinename)
renameComputer