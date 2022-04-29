#!/bin/bash

#######################################################################
#
# Remove Nessus Agent Script for Jamf Pro
#
#######################################################################

echo "Running Nessus Agent uninstaller script"

# unlink agent
/Library/NessusAgent/run/sbin/nessuscli agent unlink --force

# remove files
if [[ -d "/Library/NessusAgent" ]]; then
    if rm -rf "/Library/NessusAgent"; then
        echo "Removed /Library/NessusAgent"
    else
        echo "ERROR: failed to remove /Library/NessusAgent"
        exit 1
    fi
fi

if [[ -d "/Library/PreferencePanes/Nessus Agent Preferences.prefPane" ]]; then
    if rm -rf "/Library/PreferencePanes/Nessus Agent Preferences.prefPane"; then
        echo "Removed /Library/PreferencePanes/Nessus Agent Preferences.prefPane"
    else
        echo "ERROR: failed to remove /Library/PreferencePanes/Nessus Agent Preferences.prefPane"
        exit 1
    fi
fi

if [[ -d "/Applications/Nessus" ]]; then
    if rm -rf "/Applications/Nessus"; then
        echo "Removed /Applications/Nessus"
    else
        echo "ERROR: failed to remove /Applications/Nessus"
        exit 1
    fi
fi

# stop, unload and remove launchdaemon
/bin/launchctl stop /Library/LaunchDaemons/com.tenablesecurity.nessusagent
sleep 1
/bin/launchctl unload -w /Library/LaunchDaemons/com.tenablesecurity.nessusagent.plist

if [[ -f "/Library/LaunchDaemons/com.tenablesecurity.nessusagent.plist" ]]; then
    if rm -f "/Library/LaunchDaemons/com.tenablesecurity.nessusagent.plist"; then
        echo "Removed /Library/LaunchDaemons/com.tenablesecurity.nessusagent.plist"
    else
        echo "ERROR: failed to remove /Library/LaunchDaemons/com.tenablesecurity.nessusagent.plist"
        exit 1
    fi
fi

# Forget package
echo "Forgetting package"
pkgutilcmd="/usr/sbin/pkgutil"
receipt="com.tenablesecurity.NessusAgent.Preferences"

$pkgutilcmd --pkgs="$receipt" && $pkgutilcmd --forget "$receipt"

echo "Nessus Agent deletion complete"
