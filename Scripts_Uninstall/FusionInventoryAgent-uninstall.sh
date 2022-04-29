#!/bin/bash

#######################################################################
#
# Remove FusionInventory Agent Script for Jamf Pro
#
#######################################################################

# Remove other components
echo "Running uninstaller script"

if ! /opt/fusioninventory-agent/uninstaller.sh ; then
    echo "FusionInventory Agent uninstaller script failed"
else
    echo "FusionInventory Agent uninstaller script succeeded"
fi

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=org.fusioninventory-agent && $pkgutilcmd --forget org.fusioninventory-agent

echo "FusionInventory Agent deletion complete"
