#!/bin/bash

#######################################################################
#
# Nudge Uninstaller Script for Jamf Pro
#
#######################################################################

currentUser="$3"


# Remove the Application
/bin/rm -Rf /Applications/Utilities/Nudge.app
echo "Nudge.app has been removed"


echo "Removing LaunchDaemons and related files"

shopt -s nullglob

# Unload and remove all matching LaunchAgents
for agent in /Library/LaunchAgents/com.github.macadmins.Nudge.*; do
    if [[ -f "$agent" ]]; then
        echo "Unloading and removing LaunchAgent: $agent"
        /bin/launchctl bootout gui/$(/usr/bin/id -u "$currentUser") "$agent" 2>/dev/null || echo "Failed to bootout LaunchAgent: $agent"
        /bin/rm -f "$agent"
    fi
done

# Unload and remove all matching LaunchDaemons
for daemon in /Library/LaunchDaemons/com.github.macadmins.Nudge.*; do
    if [[ -f "$daemon" ]]; then
        echo "Unloading and removing LaunchDaemon: $daemon"
        /bin/launchctl bootout system "$daemon" 2>/dev/null || echo "Failed to bootout LaunchDaemon: $daemon"
        /bin/rm -f "$daemon"
    fi
done

shopt -u nullglob

# Forget installed packages if receipts exist
echo "Checking for installed Nudge package receipts"
for pkgid in com.github.macadmins.Nudge.Suite; do
    if ls "/private/var/db/receipts/${pkgid}"*.bom &>/dev/null; then
        echo "Forgetting package: $pkgid"
        /usr/sbin/pkgutil --forget "$pkgid" 2>/dev/null || echo "Package forget failed for $pkgid"
    fi
done
