#!/bin/bash
## postinstall script

# Set TeamViewer to not run after installation
# This is achieved by creating the following files
# before installing the package. 

guiPlist="/Library/LaunchAgents/com.teamviewer.teamviewer.plist"

current_user=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
local_uid=$(dscl /Local/Default -list /Users UniqueID | grep "$current_user" | awk '{print $2}')

if [[ -f "$guiPlist" ]]; then
    launchctl bootout "gui/${local_uid}" "${guiPlist}"
fi


