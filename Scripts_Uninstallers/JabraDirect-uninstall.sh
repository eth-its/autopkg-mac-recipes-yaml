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
app_name="Jabra Direct"
app_name2="Jabra Firmware Update"

if [[ -z "${app_name}" ]]; then
    echo "No application specified!"
    exit 1
fi

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

#######################################################
#Part II of deleter, as a second App needs to disappear (this could be done more elegantly in a for-loop (for future consideration))
#######################################################
if [[ -z "${app_name2}" ]]; then
    echo "No application specified!"
    exit 1
fi

# quit the app if running
silent_app_quit "$app_name2"


# Now remove the app
echo "Removing application: ${app_name2}"

# Add standard path if none provided
if [[ ! $app_name2 == *"/"* ]]; then
	app_to_trash="/Applications/$app_name2.app"
else
	app_to_trash="$app_name2.app"
fi

echo "Application will be deleted: $app_to_trash"
# Remove the application
/bin/rm -Rf "${app_to_trash}"

echo "Checking if $app_name2 is actually deleted..."
if [[ -d "${app_to_trash}" ]]; then
    echo "$app_name2 failed to delete"
else
    echo "$app_name2 deleted successfully"
fi

# also check to see if an additional app was ever created due to BundleID mismatch
if [[ -d "/Applications/${app_name2}/${app_name2}.app" ]]; then
    echo "Folder will be deleted: /Applications/${app_name2}/"
    /bin/rm -Rf "/Applications/${app_name2}" ||:
else
    echo "Folder not found: /Applications/${app_name2}/"
fi
if [[ -d "/Applications/${app_name2}.localized/${app_name2}.app" ]]; then
    echo "Folder will be deleted: /Applications/${app_name2}.localized/"
    /bin/rm -Rf "/Applications/${app_name2}.localized" ||:
else
    echo "Folder not found: /Applications/${app_name2}.localized/"
fi

# Try to Forget the packages if we can find a match
# Loop through the remaining parameters
pkg_1="com.jabra.directonline"
pkg_2="com.jabra.JabraFirmwareUpdate"

for (( i = 1; i < 5; i++ )); do
    pkg_id=pkg_$i
    if [[ ${!pkg_id} != "None" && ${!pkg_id} != "" ]]; then
        echo "Forgetting package ${!pkg_id}..."
        /usr/sbin/pkgutil --pkgs | /usr/bin/grep -i "${!pkg_id}" | /usr/bin/xargs /usr/bin/sudo /usr/sbin/pkgutil --forget
    fi
done

echo "$app_name deletion complete"