#!/bin/bash

#######################################################################
#
# Remove GLPI-Agent Script for Jamf Pro
#
#######################################################################

# Remove other components
echo "Running uninstaller script"

if /Applications/GLPI-Agent/uninstaller.sh ; then
    echo "GLPI-Agent uninstaller script succeeded"
elif /Applications/GLPI-Agent.app/uninstaller.sh ; then
    echo "GLPI-Agent.app uninstaller script succeeded"
else
    echo "GLPI-Agent uninstaller script failed"
fi

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=org.glpi-project.glpi-agent && $pkgutilcmd --forget org.glpi-project.glpi-agent
$pkgutilcmd --pkgs=com.teclib.glpi-agent && $pkgutilcmd --forget com.teclib.glpi-agent

echo "Stopping and unloading service"

launchctl stop org.glpi-project.glpi-agent
launchctl unload /Library/LaunchDaemons/org.glpi-project.glpi-agent.plist
rm /Library/LaunchDaemons/org.glpi-project.glpi-agent.plist
launchctl stop com.teclib.glpi-agent
launchctl unload /Library/LaunchDaemons/com.teclib.glpi-agent.plist
rm /Library/LaunchDaemons/com.teclib.glpi-agent.plist


echo "GLPI-Agent deletion complete"
