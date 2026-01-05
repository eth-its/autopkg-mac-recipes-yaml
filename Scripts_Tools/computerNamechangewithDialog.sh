#!/bin/bash

# Set Computer Name using an AppleScript dialog
# by Philippe Scholl
# Edited by Graham Pugh 2018-06-25
# Edited by Katiuscia Zehnder 2025-10-11

#renameHost
###functions

isDesktopReady() {
    c=1
	while [[ ${c} -le 30 ]]; do
        if [[ -f "/Applications/ETH Self Service.app/Contents/MacOS/Self Service" ]] && [[ "${loggedInUser}" != "_mbusersetup" ]] && [[ $( pgrep Finder | wc -l ) -gt 0 ]]; then
	        echo "[$(date)] Desktop is ready, we can continue..."
            break
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

### Script
# Check that there is an actively logged in desktop
loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
isDesktopReady
# Go ahead and rename the computer
ComputerName=$(machinename)
if [[ -z "$ComputerName" ]]; then
  echo "Abort. No Computer Name specified!"
  exit 0
fi

if jamf setComputerName -name "$ComputerName"; then
  echo "Successfully changed Computer Name to $ComputerName"
  # Inventar in Jamf Pro aktualisieren, recon done within Policy
  #jamf recon >/dev/null 2>&1 || echo "Note: recon failed (non-fatal)."
else
  echo "Failed to change Computer Name!"
  exit 1
fi
