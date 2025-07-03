#!/bin/bash

# Stop the current launchagent and remove it
launchdaemon="/Library/LaunchDaemons/corp.sap.privileges.plist"
if [[ -f "$launchdaemon" ]]; then
    /bin/launchctl bootout system "$launchdaemon" ||:
    /bin/rm "$launchdaemon"
fi

# Wait for 1 seconds
sleep 1

# Additional files to delete
echo "Deleting other files"
demote_script_location="/Library/Management/ETHZ/Privileges"
/bin/rm -Rf "$demote_script_location" ||: