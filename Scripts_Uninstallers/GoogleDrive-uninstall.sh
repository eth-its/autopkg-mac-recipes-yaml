#!/bin/bash

#######################################################################
#
# Remove Application Script for Jamf Pro - adapted for Google Drive
#
# This script can delete apps that are sandboxed and live in /Applications

# The first parameter is used to kill the app. It should be the app name or path
# as required by the pkill command.
#
#######################################################################

quit_google_drive() {
    # gracefully quit Google Drive as the current user. This is necessary to unmount the "network drive"
    current_user=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
    echo "Closing Google Drive as current user"
    su -l "$current_user" -c "/Applications/Google\ Drive.app/Contents/MacOS/Google\ Drive --quit" 2<&-

    while [[ $n -lt 10 ]]; do
        if pgrep -f "/Google Drive" ; then
            (( n=n+1 ))
            sleep 1
            echo "Graceful close attempt # $n"
        else
            echo "$app_name closed."
            break
        fi
    done
}

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
        fi
    fi
}

# firstly close Google Drive gracefully, as the current user.
quit_google_drive

# now ensure any of the other apps are closed
for app_name in "Google Drive" "Google Docs" "Google Sheets" "Google Slides"; do
    silent_app_quit "$app_name"
done

# kill the helpers (thanks @trice https://macadmins.slack.com/archives/C056155B4/p1637687411267500?thread_ts=1637685365.266300&cid=C056155B4)
killall -KILL FinderSyncAPIExtension
sleep 1
killall -KILL FinderSyncExtension
sleep 1
killall -KILL Google\ Drive
sleep 5

# unload the kext
kextunload -b com.google.dfsfuse.filesystems.dfsfuse -q 2<&- || true 

# Now remove the apps
for app_name in "Google Drive" "Google Docs" "Google Sheets" "Google Slides"; do
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
done

# Try to Forget the packages
pkgutilcmd="/usr/sbin/pkgutil"
receipts=$($pkgutilcmd --pkgs=com.google.drivefs*)
while read -r receipt; do
    $pkgutilcmd --pkgs="${receipt}" && $pkgutilcmd --forget "${receipt}"
done <<< "${receipts}"        

echo "Google Drive deletion complete"
