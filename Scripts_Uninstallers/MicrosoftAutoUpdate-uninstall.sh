#!/bin/bash

#######################################################################
#
# Application Uninstaller Script for Jamf Pro
#
# This script can delete apps that are sandboxed and live in /Applications
#
#######################################################################

silent_app_quit() {
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
            sleep 1
            /usr/bin/pkill -f "/$check_app_name"
            stillopen=$(pgrep -f "/$check_app_name")
            if -n "$stillopen" ; then
        		for process in ${stillopen}; do 
                	echo "$check_app_name have to forcefully kill $process - killing."
            		kill -9 $process
        		done
            fi
        fi

    fi
}

# Inputted variables
app_name="$4"

if [[ -z "${app_name}" ]]; then
    echo "No application specified!"
    exit 1
fi

# quit the app if running
silent_app_quit "$app_name"


# Now remove the app
echo "Removing application: ${app_name}"

echo "Application will be deleted: $app_to_trash"
# Remove the application


CURRENT_USER=$(stat -f %Su /dev/console)
USER_ID=$(id -u "$CURRENT_USER")

launchctl bootout gui/$USER_ID /Library/LaunchAgents/com.microsoft.update.agent.plist ||:
launchctl bootout system /Library/LaunchDaemons/com.microsoft.autoupdate.helper.plist ||:

rm -rf /Library/LaunchAgents/com.microsoft.update.agent.plist
rm -rf /Library/LaunchDaemons/com.microsoft.autoupdate.helper.plist
pkill com.microsoft.autoupdate.helper
rm -rf /Library/PrivilegedHelperTools/com.microsoft.autoupdate.helper
rm -rf /Library/Application\ Support/Microsoft/MAU2.0

echo "$app_name deleted successfully"

# Try to Forget the packages if we can find a match
# Loop through the remaining parameters
pkg_1="com.microsoft.package.Microsoft_AutoUpdate.app"
pkg_2="$6"
pkg_3="$7"
pkg_4="$8"
pkg_5="$9"
for (( i = 1; i < 5; i++ )); do
    pkg_id=pkg_$i
    if [[ ${!pkg_id} != "None" && ${!pkg_id} != "" ]]; then
        echo "Forgetting package ${!pkg_id}..."
        /usr/sbin/pkgutil --pkgs | /usr/bin/grep -i "${!pkg_id}" | /usr/bin/xargs /usr/bin/sudo /usr/sbin/pkgutil --forget
    fi
done

echo "$app_name deletion complete"