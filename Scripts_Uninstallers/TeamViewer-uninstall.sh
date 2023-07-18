#!/bin/bash

#######################################################################
#
# Application Uninstaller Script for Jamf Pro
#
# This script can delete apps that are sandboxed and live in /Applications
#
# Adapted for TeamViewer
#
#######################################################################

loggedInUser=$( /bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }' )
loggedInUserHome=$( /usr/bin/dscl . -read "/Users/$loggedInUser" | grep NFSHomeDirectory: | cut -c 19- | head -n 1 )

function silent_app_quit() {
    # silently kill the application.
    # add .app to end of string if not supplied
    app_name="${app_name/\.app/}"            # remove any .app
    check_app_name="${app_name/\(/\\(}"       # escape any brackets for the pgrep
    check_app_name="${check_app_name/\)/\\)}"  # escape any brackets for the pgrep
    check_app_name="${check_app_name}.app"     # add the .app back
    if pgrep -f "/${check_app_name}" ; then
        echo "Closing $check_app_name"
        /usr/bin/osascript -e "quit app \"$app_name\"" &
        sleep 1

        # double-check
        n=0
        while [[ $n -lt 10 ]]; do
            if pgrep -f "/$check_app_name" ; then
                (( n=n+1 ))
                sleep 1
				echo "Graceful close attempt # $n"
            else
                echo "$app_name closed."
                break
            fi
        done
        if pgrep -f "/$check_app_name" ; then
            echo "$check_app_name failed to quit - killing."
            /usr/bin/pkill -f "/$check_app_name"
        fi
    fi
}

# Inputted variables
app_name="TeamViewer"

# quit the app if running
silent_app_quit "$app_name"

# Now remove the app
echo "Removing application: ${app_name}"

# Add standard path if none provided
if [[ ! $app_name == *"/"* ]]; then
	app_to_trash="/Applications/$app_name.app"
else
	app_to_trash="$app_name.app"
fi

# chown to the user to account for the "clever" uninstaller
chmod -R 755 "${app_to_trash}"
chown -R "$loggedInUser:staff" "${app_to_trash}"

echo "Application will be deleted: $app_to_trash"
# Remove the application
/bin/rm -Rf "${app_to_trash}"

echo "Checking if $app_name is actually deleted..."
if [[ -d "${app_to_trash}" ]]; then
    echo "$app_name failed to delete"
else
    echo "$app_name deleted successfully"
fi

# also check to see if an additional app was ever created due to BundleID mismatch
if [[ -d "/Applications/${app_name}/${app_name}.app" ]]; then
    echo "Folder will be deleted: /Applications/${app_name}/"
    /bin/rm -Rf "/Applications/${app_name}" ||:
else
    echo "Folder not found: /Applications/${app_name}/"
fi
if [[ -d "/Applications/${app_name}.localized/${app_name}.app" ]]; then
    echo "Folder will be deleted: /Applications/${app_name}.localized/"
    /bin/rm -Rf "/Applications/${app_name}.localized" ||:
else
    echo "Folder not found: /Applications/${app_name}.localized/"
fi

# Additional files to delete
echo "Deleting other files"

/bin/rm -f /Library/LaunchAgents/com.teamviewer.teamviewer.plist ||:
/bin/rm -f /Library/LaunchAgents/com.teamviewer.teamviewer_desktop.plist ||:
/bin/rm -f /Library/LaunchDaemons/com.teamviewer.Helper.plist ||:
/bin/rm -f /Library/PrivilegedHelperTools/com.teamviewer.Helper ||:
/bin/rm -rf "/Library/Application Support/TeamViewer" ||:
/bin/rm -rf "$loggedInUserHome/Library/Application Support/TeamViewer" ||:
/bin/rm -rf "$loggedInUserHome/Library/Caches/com.teamviewer.TeamViewer" ||:

# Forget packages (works for all versions)
echo "Forgetting packages"
tv_pkgs=$( /usr/sbin/pkgutil --pkgs | /usr/bin/grep com.teamviewer.teamviewer | /usr/bin/grep -v com.teamviewer.TeamViewerQS )
while read -r pkg; do
    /usr/sbin/pkgutil --forget "$pkg" ||:
done <<< "$tv_pkgs"
