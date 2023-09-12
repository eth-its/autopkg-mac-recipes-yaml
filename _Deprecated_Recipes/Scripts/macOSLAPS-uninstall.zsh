#!/bin/bash
# shellcheck shell=bash

#######################################################################
#
# Remove macOSLAPS Script for Jamf Pro
#
#######################################################################

# Remove components
if [[ -d "/usr/local/laps" ]]; then
    rm -rf /usr/local/laps
fi
# remove launchdaemon
if [[ -f "/Library/LaunchDaemons/edu.psu.macoslaps-check.plist" ]]; then
    rm "/Library/LaunchDaemons/edu.psu.macoslaps-check.plist"
    /bin/launchctl bootout edu.psu.macoslaps-check
fi
# remove keychain entry
if security find-generic-password -a "LAPS Password"; then
    security delete-generic-password -a "LAPS Password"
fi

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=edu.psu.macOSLAPS && $pkgutilcmd --forget edu.psu.macOSLAPS

echo "macOSLAPS deletion complete"
