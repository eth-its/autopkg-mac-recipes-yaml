#!/bin/bash

#######################################################################
#
# Remove IdeaShare.app Script for Jamf Pro
#######################################################################

function silent_app_quit() {
    # silently kill the application.
    # add .app to end of string if not supplied
    app_name="${app_name/\.app/}"            # remove any .app
    check_app_name="${app_name/\(/\\(}"       # escape any brackets for the pgrep
    check_app_name="${check_app_name/\)/\\)}"  # escape any brackets for the pgrep
    check_app_name="${check_app_name}.app"     # add the .app back
    if pgrep -f "/${check_app_name}" ; then
        echo "Closing $app_name"
        /usr/bin/osascript -e "quit app \"$app_name\"" &
        sleep 1

        # double-check
        n=0
        while [[ $n -lt 10 ]]; do
            if pgrep -f "$check_app_name" ; then
                (( n=n+1 ))
                sleep 1
				echo "Graceful close attempt # $n"
            else
                echo "$app_name closed."
                break
            fi
        done
        if pgrep -f "$check_app_name" ; then
            echo "$app_name failed to quit - killing."
            /usr/bin/pkill -f "$check_app_name"
        fi
    fi
}

# MAIN

app_name="IdeaShare"

# quit the app if running
silent_app_quit "$app_name"

# Now remove the app
echo "Removing application: ${check_app_name}"

app_to_trash="/Applications/$check_app_name"

# 1. Remove the application
if [[ -d "${app_to_trash}" ]]; then
    if /bin/rm -Rf "${app_to_trash}"; then
        echo "$app_name deleted successfully"
    else
        echo "$app_name failed to delete"
        exit 1
    fi
else
    echo "${app_to_trash} not found"
fi

/usr/sbin/pkgutil --pkgs=com.thundersoft.IdeaShare && /usr/sbin/pkgutil --forget com.thundersoft.IdeaShare

# 5. remove other files
# Remove files and directories related to IdeaShare for Mac OSX.
echo "Removing any remaining IdeaShare Drivers,files and directories..."
rm -rf /Library/Audio/Plug-Ins/HAL/IdeaShareDriver.driver ||:
launchctl kickstart -kp system/com.apple.audio.coreaudiod ||:
 killall -9 coreaudiod ||:

echo "$app_name deletion complete"
