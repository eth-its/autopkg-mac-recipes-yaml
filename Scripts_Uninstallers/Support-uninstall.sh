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
    /bin/rm -Rf "/Applications/${app_name}" || true
else
    echo "Folder not found: /Applications/${app_name}/"
fi
if [[ -d "/Applications/${app_name}.localized/${app_name}.app" ]]; then
    echo "Folder will be deleted: /Applications/${app_name}.localized/"
    /bin/rm -Rf "/Applications/${app_name}.localized" || true
else
    echo "Folder not found: /Applications/${app_name}.localized/"
fi

# Additional files to delete
echo "Deleting other files"

# Get logged-in GUI user for LaunchAgent bootout
loggedInUser=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }')
loggedInUID=""
if [[ -n "$loggedInUser" ]]; then
    loggedInUID=$(/usr/bin/id -u "$loggedInUser" 2>/dev/null)
fi

# Bootout LaunchDaemons
if [[ -f "/Library/LaunchDaemons/nl.root3.support.plist" ]]; then
    launchctl bootout system "/Library/LaunchDaemons/nl.root3.support.plist" >/dev/null 2>&1 || true
fi

if [[ -f "/Library/LaunchDaemons/nl.root3.support.helper.plist" ]]; then
    launchctl bootout system "/Library/LaunchDaemons/nl.root3.support.helper.plist" >/dev/null 2>&1 || true
fi

# Bootout LaunchAgent in logged-in user's GUI context
if [[ -n "$loggedInUID" && -f "/Library/LaunchAgents/nl.root3.support.plist" ]]; then
    launchctl bootout "gui/$loggedInUID" "/Library/LaunchAgents/nl.root3.support.plist" >/dev/null 2>&1 || true
else
    echo "No logged-in GUI user found or LaunchAgent plist missing"
fi

# Kill remaining helper / support related processes
/usr/bin/pkill -f "nl.root3.support.helper" >/dev/null 2>&1 || true
/usr/bin/pkill -f "nl.root3.support" >/dev/null 2>&1 || true
/usr/bin/pkill -f "/Applications/Support.app" >/dev/null 2>&1 || true

# Remove files only if they exist
if [[ -f "/Library/LaunchAgents/nl.root3.support.plist" ]]; then
    /bin/rm -f "/Library/LaunchAgents/nl.root3.support.plist" || true
fi

if [[ -f "/Library/LaunchDaemons/nl.root3.support.plist" ]]; then
    /bin/rm -f "/Library/LaunchDaemons/nl.root3.support.plist" || true
fi

if [[ -f "/Library/LaunchDaemons/nl.root3.support.helper.plist" ]]; then
    /bin/rm -f "/Library/LaunchDaemons/nl.root3.support.helper.plist" || true
fi

if [[ -f "/Library/PrivilegedHelperTools/nl.root3.support.helper" ]]; then
    /bin/rm -f "/Library/PrivilegedHelperTools/nl.root3.support.helper" || true
fi

if [[ -d "/Library/Management/ETHZ/SupportApp" ]]; then
    /bin/rm -rf "/Library/Management/ETHZ/SupportApp" || true
fi



# Forget packages (works for all versions)
echo "Forgetting packages"
/usr/sbin/pkgutil --forget nl.root3.support || true
/usr/sbin/pkgutil --forget nl.root3.support.helper || true