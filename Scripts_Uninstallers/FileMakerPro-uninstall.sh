#!/bin/bash

#######################################################################
#
# Remove Application Script for Jamf Pro - adapted for FileMaker Pro
#
# This script can delete apps that are sandboxed and live in /Applications

# The first parameter is used to kill the app. It should be the app name or path
# as required by the pkill command.
#
#######################################################################

# Inputted variables
app_name="FileMaker Pro"
check_app_name="FileMaker Pro.app" 

# silently kill the application.
if pgrep -f "/${check_app_name}" ; then
    echo "Closing $app_name"
    /usr/bin/osascript -e "quit app \"$app_name\"" &
    sleep 1

    # double-check
    n=0
    while [[ $n -lt 10 ]]; do
        if pgrep -f "/${check_app_name}" ; then
            (( n=n+1 ))
            sleep 1
            echo "Graceful close attempt # $n"
        else
            echo "$app_name closed."
            break
        fi
    done
    if pgrep -f "/${check_app_name}" ; then
        echo "$app_name failed to quit - killing."
        /usr/bin/pkill -f "/$check_app_name"
    fi
fi

# Now remove the app
echo "Removing application: ${app_name}"

find /Applications -type d -name "FileMaker Pro.app" -maxdepth 1 -exec rm -rf {} +

echo "Checking if $app_name is actually deleted..."
[[ $(find /Applications -type d -name "FileMaker Pro.app" -maxdepth 1) ]] && echo "$app_name failed to delete" || echo "$app_name deleted successfully"

# Delete the shared files
echo "Removing /Users/Shared/FileMaker"
rm -Rf "/Users/Shared/FileMaker" && echo "/Users/Shared/FileMaker removed" || echo "/Users/Shared/FileMaker was not removed"

# Try to Forget the package(s)
for package in ch.ethz.id.pkg.FileMakerPro19Installer ch.ethz.id.pkg.FileMakerPro20Installer; do
    /usr/sbin/pkgutil --pkgs="$package" && usr/sbin/pkgutil --forget "$package"
done

echo "$app_name deletion complete"
