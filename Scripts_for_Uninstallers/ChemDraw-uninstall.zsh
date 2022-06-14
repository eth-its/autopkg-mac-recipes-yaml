#!/bin/bash

#######################################################################
#
# ChemDraw Uninstall Script for Jamf Pro
#
# This script can delete apps that are sandboxed and live in /Applications
#
#######################################################################

# Inputted variables
appName="ChemDraw"
MajorVersion="$4"

function silent_app_quit() {
    # silently kill the application.
    appName="$1"
    if [[ $(pgrep -ix "$appName") ]]; then
        echo "Closing $appName"
        /usr/bin/osascript -e "quit app \"$appName\""
        sleep 1

        # double-check
        countUp=0
        while [[ $countUp -le 10 ]]; do
            if [[ -z $(pgrep -ix "$appName") ]]; then
                echo "$appName closed."
                break
            else
                let countUp=$countUp+1
                sleep 1
            fi
        done
        if [[ $(pgrep -x "$appName") ]]; then
            echo "$appName failed to quit - killing."
            /usr/bin/pkill "$appName"
        fi
    fi
}

if [[ -z "${appName}" ]]; then
    echo "No application specified!"
    exit 1
fi

# quit the app if running
silent_app_quit "$appName"

# Now remove the app
echo "Removing application: ${appName} ${MajorVersion}"

# Add standard path if none provided
appToDelete=$(find /Applications -type d -name "${appName} ${MajorVersion}*" -maxdepth 1)

if [[ -d "$appToDelete" ]]; then
    echo "Application will be deleted: $appToDelete"
    # Remove the application
    /bin/rm -rf "${appToDelete}"
    echo "Checking if $appName ${MajorVersion} is actually deleted..."
    if [[ -d "${appToDelete}" ]]; then
        echo "$appName ${MajorVersion} failed to delete"
    else
        echo "$appName ${MajorVersion} deleted successfully"
    fi
fi

# Try to Forget the packages if we can find a match
/usr/sbin/pkgutil --pkgs=com.perkinselmer.ChemDraw${MajorVersion}.pkg && /usr/sbin/pkgutil --forget com.perkinselmer.ChemDraw${MajorVersion}.pkg

echo "$appName  ${MajorVersion} deletion complete"
