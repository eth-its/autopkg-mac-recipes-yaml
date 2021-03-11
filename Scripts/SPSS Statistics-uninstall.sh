#!/bin/bash

#######################################################################
#
# %NAME% Uninstaller Script for Jamf Pro
#
#######################################################################

function silent_app_quit() {
    # silently kill the application.
    if pgrep -f "/$app_name" ; then
        echo "Closing $app_name"
        /usr/bin/osascript -e "quit app \"$app_name\"" &
        sleep 1

        # double-check
        n=0
        while [[ $n -lt 10 ]]; do
            if pgrep -f "/$app_name" ; then
                (( n=n+1 ))
                sleep 1
				echo "Graceful close attempt # $n"
            else
                echo "$app_name closed."
                break
            fi
        done
        if pgrep -f "/$app_name" ; then
            echo "$app_name failed to quit - killing."
            /usr/bin/pkill -f "$app_name"
        fi
    fi
}

# Inputted variables
app_name="SPSS Statistics.app"
major_version="$4"

# quit the app if running
silent_app_quit "$app_name"


# Now remove the app
echo "Removing application: ${app_name}"

# Add standard path if none provided
folder_to_trash="/Applications/IBM SPSS Statistics $major_version"

echo "Entire folder will be deleted: $folder_to_trash"
# Remove the application
/bin/rm -Rf "${folder_to_trash}"

echo "Checking if $app_name is actually deleted..."
if [[ -d "${folder_to_trash}" ]]; then
    echo "$app_name failed to delete"
else
    echo "$app_name deleted successfully"
fi

# Try to Forget the packages if we can find a match
# Loop through the remaining parameters
pkg_1="com.ibm.spss.statistics.installer"
pkg_2="com.ibm.spss.statistics.licensing"
for (( i = 1; i < 2; i++ )); do
    pkg_id=pkg_$i
    echo "Forgetting package ${!pkg_id}..."
    /usr/sbin/pkgutil --pkgs="${!pkg_id}" && /usr/sbin/pkgutil --forget "${!pkg_id}"
done

# remove license indicator files
if rm "/Library/Management/SPSSStatistics/$major_version/node_license_activated" 2> /dev/null ; then 
    # clear out the Node license 
    echo "Node license removed" 
fi
if rm "/Library/Management/SPSSStatistics/$major_version/floating_license_present" 2> /dev/null ; then 
    # clear out the Floating license 
    echo "Floating license removed" 
fi
if rm -Rf "/Library/Management/SPSSStatistics/$major_version" ; then
    echo "License removal complete"
fi

# finish
echo "$app_name deletion complete"