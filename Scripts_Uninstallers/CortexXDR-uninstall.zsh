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
uninstaller="/Applications/Cortex XDR Uninstaller.app"

# uninstaller password in Parameter 4
password=""
if [[ $4 ]]; then
    password="$4"
fi

# now run the uninstaller (requires password in parameter 4) or open the app
if [[ $password ]]; then
    if "$uninstaller/Contents/Resources/cortex_xdr_uninstaller_tool" "$password"; then
        echo "Cortex XDR uninstallation complete"
    else
        echo "Cortex XDR uninstallation failed"
        chflags nohidden "$uninstaller"
        exit 1
    fi
else
    echo "No password provided, so cannot run the automated uninstaller. Opening the uninstaller app instead"
    chflags nohidden "$uninstaller"
fi

# now remove the uninstaller from all locations if Cortex has been deleted.
if [[ ! -d "/Applications/Cortex XDR.app" ]]; then
    rm -rf "$uninstaller" ||:
    rm -rf "/Library/Management/PaloAlto" ||:
else
    echo "Cortex uninstallation failed"
    chflags nohidden "$uninstaller"
    exit 1
fi

# Try to Forget the packages if we can find a match
/usr/sbin/pkgutil --pkgs=com.paloaltonetworks.pkg.cortex && /usr/sbin/pkgutil --forget com.paloaltonetworks.pkg.cortex

echo "Cortex XDR uninstaller script complete"
