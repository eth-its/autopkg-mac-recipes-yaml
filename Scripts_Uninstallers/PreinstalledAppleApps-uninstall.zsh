#!/bin/zsh
# shellcheck shell=bash

#######################################################################
#
# Uninstall Preinstalled Apple Apps
#
#######################################################################

# All the other parameters can be package IDs to delete
PreinstalledAppleApps=( "Keynote" "Numbers" "Pages" "GarageBand" "iMovie" )

echo "Removing preinstalled Apple applications..."

for appName in "${PreinstalledAppleApps[@]}"; do
    if [[ -d "/Applications/$appName.app" ]]; then
        echo "Deleting '/Applications/$appName.app'"
        jamf policy -event "$appName-uninstall"
    fi
done
