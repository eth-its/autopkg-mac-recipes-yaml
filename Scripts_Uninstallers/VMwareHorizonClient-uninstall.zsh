#!/bin/zsh
# shellcheck shell=bash

#######################################################################
#
# VMware Horizon Client Uninstall Script for Jamf Pro
#
# This script can delete apps that are sandboxed and live in /Applications
#
#######################################################################

# Inputted variables
appName="VMware Horizon Client"
appNameCheck="vmware-view"

function silent_app_quit() {
    # silently kill the application.
    if [[ $(pgrep -ix "$appNameCheck") ]]; then
    	echo "Closing $appName"
		/usr/bin/killall "$appNameCheck"
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
# Remove the application
[[ -d "${appToDelete}" ]] && /bin/rm -rf "${appToDelete}"

echo "Checking if $appName is actually deleted..."
if [[ -d "${appToDelete}" ]]; then
    echo "$appName failed to delete"
else
    echo "$appName deleted successfully"
fi

# additionally remove VMware Horizon URL Filter app

# Get the logged-in user's username for this
loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

folderToDelete="/Users/$loggedInUser/Library/Application Support/VMware Horizon View Client"
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
pkg_id="com.vmware.horizon.pkg"
echo "Forgetting package $pkg_id..."
/usr/sbin/pkgutil --pkgs | /usr/bin/grep -i $pkg_id | /usr/bin/xargs /usr/bin/sudo /usr/sbin/pkgutil --forget

echo "$appName deletion complete"
