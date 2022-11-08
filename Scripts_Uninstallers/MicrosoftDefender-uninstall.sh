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
else
    echo "Microsoft Defender uninstaller not found. Cannot proceed. Try Open Finder > Applications. Right click on Microsoft Defender for Endpoint > Move to Trash."
fi
