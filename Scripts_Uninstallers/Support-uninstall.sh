#!/bin/bash

#######################################################################
#
# Application Uninstaller Script for Jamf Pro
#
# This script can delete apps that are sandboxed and live in /Applications
#
# Adapted for Support app
#
#######################################################################

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
app_name="Support"

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
launchctl bootout system "/Library/LaunchDaemons/nl.root3.support.plist" &> /dev/null
/bin/rm -f /Library/LaunchAgents/nl.root3.support.plist ||:
/bin/rm -f /Library/LaunchDaemons/nl.root3.support.plist ||:
/bin/rm -f /usr/local/bin/SupportHelper ||:
/bin/rm -rf /Library/Management/ETHZ/SupportApp ||:


# Forget packages (works for all versions)
echo "Forgetting packages"
/usr/sbin/pkgutil --forget nl.root3.support ||:
/usr/sbin/pkgutil --forget nl.root3.support.helper ||:
