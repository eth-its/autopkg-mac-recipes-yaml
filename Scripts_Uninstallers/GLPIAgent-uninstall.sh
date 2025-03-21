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
