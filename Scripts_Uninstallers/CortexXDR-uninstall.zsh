#!/bin/zsh
# shellcheck shell=bash

#######################################################################
#
# Cortex XDR Uninstall Script for Jamf Pro
#
# This script depends on The Cortex XDR uninstaller being saved on the device
#
#######################################################################

# location of saved XDR uninstaller
uninstaller_location="/Library/Management/PaloAlto/CortexXDR/Cortex XDR Uninstaller.app"

# uninstaller password in Parameter 4
password=""
if [[ $4 ]]; then
    password="$4"
fi

# remove an existing uninstaller
if [[ -d "/Applications/Cortex XDR Uninstaller.app" ]]; then
    echo "Removing existing Cortex XDR uninstaller"
    rm -rf "/Applications/Cortex XDR Uninstaller.app"
fi

# copy the uninstaller to /Applications
if [[ -d "$uninstaller_location" ]]; then
    echo "Copying Cortex XDR uninstaller to /Applications"
    mv "$uninstaller_location" /Applications/
else
    echo "Could not find Cortex XDR uninstaller"
    exit 1
fi

# now run the uninstaller (requires password in parameter 4) or open the app
if [[ $password ]]; then
    if "/Applications/Cortex XDR Uninstaller.app/Contents/Resources/cortex_xdr_uninstaller_tool" "$password"; then
        echo "Cortex XDR uninstallation complete"
    else
        echo "Cortex XDR uninstallation failed"
        /usr/bin/open -a "/Applications/Cortex XDR Uninstaller.app"
        exit 1
    fi
else
    echo "No password provided, so cannot run the automated uninstaller. Opening the uninstaller app instead"
    /usr/bin/open -a "/Applications/Cortex XDR Uninstaller.app"
fi

# now remove the uninstaller from all locations if Cortex has been deleted.
if [[ ! -d "/Applications/Cortex XDR.app" ]]; then
    rm -rf "/Applications/Cortex XDR Uninstaller.app" ||:
    rm -rf "/Library/Management/PaloAlto" ||:
else
    echo "Cortex uninstallation failed"
    /usr/bin/open -a "/Applications/Cortex XDR Uninstaller.app"
    exit 1
fi

# Try to Forget the packages if we can find a match
/usr/sbin/pkgutil --pkgs=com.paloaltonetworks.pkg.cortex && /usr/sbin/pkgutil --forget com.paloaltonetworks.pkg.cortex

echo "Cortex XDR uninstaller script complete"
