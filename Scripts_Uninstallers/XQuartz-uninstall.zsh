#!/bin/zsh
# shellcheck shell=bash

## XQuartz uninstaller
## details from https://discussions.apple.com/thread/4162096

#######################################################################
#
# Unison Uninstaller Script for Jamf Pro
#
# This script can delete apps that are sandboxed and live in /Applications
#
#######################################################################

# Inputted variables
app_name="XQuartz"

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

app_to_trash="/Applications/Utilities/XQuartz.app"

echo "Application will be deleted: $app_name"

# Remove the application
/bin/rm -rf "$app_to_trash" ||:

echo "Checking if $app_name is actually deleted..."
if [[ -d "${app_to_trash}" ]]; then
    echo "$app_name failed to delete"
else
    echo "$app_name deleted successfully"
fi

# remove launch agent and daemon
# < 2.8
[[ -f /Library/LaunchAgents/org.macosforge.xquartz.startx.plist ]] && launchctl unload /Library/LaunchAgents/org.macosforge.xquartz.startx.plist
# 2.8+
[[ -f /Library/LaunchAgents/org.xquartz.startx.plist ]] && launchctl unload /Library/LaunchAgents/org.xquartz.startx.plist
echo ".. XQuartz launch agent removed"

# < 2.8
[[ -f /Library/LaunchDaemons/org.macosforge.xquartz.privileged_startx.plist ]] && launchctl unload /Library/LaunchDaemons/org.macosforge.xquartz.privileged_startx.plist
# 2.8+
[[ -f /Library/LaunchDaemons/org.xquartz.privileged_startx.plist ]] && launchctl unload /Library/LaunchDaemons/org.xquartz.privileged_startx.plist
echo ".. XQuartz launch daemon removed"

# remove files
/bin/rm -rf /opt/X11* ||:
/bin/rm -rf /Library/Launch*/org.macosforge.xquartz.* ||:
/bin/rm -rf /Library/Launch*/org.xquartz.* ||:
/bin/rm -rf /etc/*paths.d/*XQuartz ||:
echo ".. XQuartz files removed"

# forget package
/usr/sbin/pkgutil --pkgs=org.macosforge.xquartz.pkg && /usr/sbin/pkgutil --forget org.macosforge.xquartz.pkg
/usr/sbin/pkgutil --pkgs=org.xquartz.pkg && /usr/sbin/pkgutil --forget org.xquartz.pkg

echo ".. XQuartz package forgotten"

echo "** XQuartz removal complete**"
