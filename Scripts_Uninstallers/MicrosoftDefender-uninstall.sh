#!/bin/bash

#######################################################################
#
# MicrosoftDefender-uninstall.sh Script for Jamf Pro
#
#######################################################################

# use built-in command for uninstallation
uninstaller="/Library/Application Support/Microsoft/Defender/uninstall/uninstall"

if [[ -f "$uninstaller" ]]; then
    # try running the uninstaller
    if "$uninstaller"; then
    echo "Microsoft Defender uninstallation complete"
    else
        echo "Something went wrong during the uninstallation of Microsoft Defender"
    fi
elif [[ -d "/Applications/Microsoft Defender.app" ]]; then
    echo "Microsoft Defender uninstaller not found. Deleting it manually instead."
    rm -Rf "/Applications/Microsoft Defender.app" ||:
else
    echo "Microsoft Defender does not appear to be installed on this device."
fi
