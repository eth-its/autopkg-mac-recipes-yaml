#!/bin/bash

#######################################################################
#
# Remove GLPI-Agent Script for Jamf Pro
#
#######################################################################

# Remove other components
echo "Running uninstaller script"

if ! /Applications/GLPI-Agent.app/uninstaller.sh ; then
    echo "GLPI-Agent uninstaller script failed"
else
    echo "GLPI-Agent uninstaller script succeeded"
fi

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=org.glpi-project.glpi-agent && $pkgutilcmd --forget org.glpi-project.glpi-agent

echo "GLPI-Agent deletion complete"
