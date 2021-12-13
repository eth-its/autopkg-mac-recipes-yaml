#!/bin/bash

#######################################################################
#
# Application Uninstaller Script for Jamf Pro
#
# This script can delete apps that are sandboxed and live in /Applications
#
# Adapted for TeXShop app
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
app_name="TeXShop"

# quit the app if running
silent_app_quit "$app_name"

# Now remove the app
echo "Removing application: ${app_name}"

# Remove the application (standalone location)
/bin/rm -Rf "/Applications/$app_name.app" ||:

# Remove the application (standalone location)
/bin/rm -Rf "/Applications/TeX/$app_name.app" ||:

echo "Checking if $app_name is actually deleted..."
if [[ -d "/Applications/$app_name.app" || -d "/Applications/TeX/$app_name.app" ]]; then
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

# Remove the TeX folder if it's empty
if [[ -d "/Applications/TeX" ]]; then
    # remove .DS_Store
    rm -Rf "/Applications/TeX/.DS_Store"
    # now check if the directory is empty
    if [[ "$(ls -A "/Applications/TeX")" ]]; then
        echo "/Applications/TeX not empty - leaving alone"
    else
        echo "/Applications/TeX is empty - deleting"
        rm -Rf "/Applications/TeX"
    fi
else
    echo "/Applications/TeX not present"
fi

# Forget packages (works for all versions)
echo "Forgetting packages"
/usr/sbin/pkgutil --forget edu.uoregon.TeXShop ||:
