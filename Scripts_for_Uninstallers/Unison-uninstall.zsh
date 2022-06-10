#!/bin/zsh
# shellcheck shell=bash

#######################################################################
#
# Unison Uninstaller Script for Jamf Pro
#
# This script can delete apps that are sandboxed and live in /Applications
#
#######################################################################

# Inputted variables
app_name="Unison"

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

if [[ -z "${app_name}" ]]; then
    echo "No application specified!"
    exit 1
fi

# quit the app if running
silent_app_quit "$app_name"

# Now remove the app
echo "Removing application: ${app_name}"

# remove cltool
cltool_path="/usr/local/bin/unison"
if [[ -f "$cltool_path" ]]; then
    rm -f "$cltool_path"
fi

echo "Checking if $app_name is actually deleted..."
if [[ $(find /Applications -type d -name "Enpass*" -maxdepth 1) ]]; then 
    echo "$app_name failed to delete"
else
    echo "$app_name deleted successfully"
fi

# Try to Forget the packages if we can find a match
# Loop through the remaining parameters
        echo "Forgetting package in.sinew.Enpass-Desktop..."
        /usr/sbin/pkgutil --pkgs | /usr/bin/grep -i "in.sinew.Enpass-Desktop" | /usr/bin/xargs /usr/bin/sudo /usr/sbin/pkgutil --forget

echo "$app_name deletion complete"