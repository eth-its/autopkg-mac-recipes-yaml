#!/bin/bash

#######################################################################
#
# MindManager-uninstall.sh Script for Jamf Pro
#
#######################################################################

function silent_app_quit() {
    # silently kill the application.
    # remove .app from end of string if supplied
    app_name="${1/.app/}"
    if [[ $(pgrep -ix "$app_name") ]]; then
    	echo "Closing $app_name"
    	/usr/bin/osascript -e "quit app \"$app_name\""
    	sleep 1

    	# double-check
    	countUp=0
    	while [[ $countUp -le 10 ]]; do
    		if [[ -z $(pgrep -ix "$app_name") ]]; then
    			echo "$app_name closed."
    			break
    		else
    			(( countUp++ ))
    			sleep 1
    		fi
    	done
        if [[ $(pgrep -x "$app_name") ]]; then
    	    echo "$app_name failed to quit - killing."
    	    /usr/bin/pkill "$app_name"
        fi
    fi
}

function delete_app() {
    # Now remove the app
    echo "Removing application: ${app_name}"

    # Add .app to end when providing just a name e.g. "TeamViewer"
    if [[ ! $app_name == *".app"* ]]; then
        app_name=$app_name".app"
    fi

    # Add standard path if none provided
    if [[ ! $app_name == *"/"* ]]; then
        appToDelete="/Applications/$app_name"
    else
        appToDelete="$app_name"
    fi

    # Remove the application
    if [[ -d "${appToDelete}" ]]; then
        echo "Application will be deleted: $appToDelete"
        /bin/rm -Rf "${appToDelete}"
        echo "Checking if $app_name is actually deleted..."
        if [[ -d "${appToDelete}" ]]; then
            echo "$app_name failed to delete"
        else
            echo "$app_name deleted successfully"
        fi
    else
        echo "Application not present: $appToDelete"
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
}

app_name="MindManager"
silent_app_quit "$app_name"
delete_app "$app_name"

app_name="Mindjet MindManager.app"
silent_app_quit "$app_name"
delete_app "$app_name"


# Try to Forget the packages if we can find a match
for pkg in $(/usr/sbin/pkgutil --pkgs=com.mindjet.mindmanager.*); do
    echo "Forgetting package $pkg..."
    /usr/sbin/pkgutil --pkgs="$pkg" | /usr/bin/xargs /usr/bin/sudo /usr/sbin/pkgutil --forget
done

echo "$app_name deletion complete"
