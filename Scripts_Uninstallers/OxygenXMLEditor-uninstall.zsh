#!/bin/zsh
# shellcheck shell=bash

#######################################################################
#
# Omnissa Horizon Client Uninstall Script for Jamf Pro
#
# This script can delete apps that are sandboxed and live in /Applications
#
#######################################################################

# Inputted variables
appName="Oxygen XML Editor"
appNameCheck="$appName"

function silent_app_quit() {
    # silently kill the application
    if [[ $(pgrep -f "$appNameCheck") ]]; then
    	echo "Closing $appName"
		pkill -f "$appNameCheck"
    fi
}

if [[ -z "${appName}" ]]; then
    echo "No application specified!"
    exit 1
fi

# quit the app if running
silent_app_quit "$appName"

# Add .app to end when providing just a name e.g. "TeamViewer"
appName=$appName".app"

# Now remove the app
echo "Removing application: ${appName}"

# Add standard path if none provided
appToDelete="/Applications/$appName"
echo "Application will be deleted: $appToDelete"
# Remove the folder that contains all the applications

folderToDelete="/Applications/Oxygen"
if [[ -d "${folderToDelete}" ]]; then
	echo "Folder will be deleted: $folderToDelete"
	/bin/rm -rf "${folderToDelete}"
fi

echo "Checking if $folderToDelete is actually deleted..."
if [[ -d "${folderToDelete}" ]]; then
    echo "$folderToDelete failed to delete"
else
    echo "$folderToDelete deleted successfully"
fi

# Forget the package
pkg_id="uk.ac.ox.orchard.pkg.oxygenxmleditor"
echo "Forgetting package $pkg_id..."
/usr/sbin/pkgutil --pkgs | /usr/bin/grep -i $pkg_id | /usr/bin/xargs /usr/bin/sudo /usr/sbin/pkgutil --forget

echo "$appName deletion complete"
