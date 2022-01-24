#!/bin/bash

#######################################################################
#
# MindManager-uninstall.sh Script for Jamf Pro
#
#######################################################################

function silent_app_quit() {
    # silently kill the application.
    # remove .app from end of string if supplied
    appName="${1/.app/}"
    if [[ $(pgrep -ix "$appName") ]]; then
    	echo "Closing $appName"
    	/usr/bin/osascript -e "quit app \"$appName\""
    	sleep 1

    	# double-check
    	countUp=0
    	while [[ $countUp -le 10 ]]; do
    		if [[ -z $(pgrep -ix "$appName") ]]; then
    			echo "$appName closed."
    			break
    		else
    			(( countUp++ ))
    			sleep 1
    		fi
    	done
        if [[ $(pgrep -x "$appName") ]]; then
    	    echo "$appName failed to quit - killing."
    	    /usr/bin/pkill "$appName"
        fi
    fi
}

function delete_app() {
    # Now remove the app
    echo "Removing application: ${appName}"

    # Add .app to end when providing just a name e.g. "TeamViewer"
    if [[ ! $appName == *".app"* ]]; then
        appName=$appName".app"
    fi

    # Add standard path if none provided
    if [[ ! $appName == *"/"* ]]; then
        appToDelete="/Applications/$appName"
    else
        appToDelete="$appName"
    fi

    # Remove the application
    if [[ -d "${appToDelete}" ]]; then
        echo "Application will be deleted: $appToDelete"
        /bin/rm -Rf "${appToDelete}"
        echo "Checking if $appName is actually deleted..."
        if [[ -d "${appToDelete}" ]]; then
            echo "$appName failed to delete"
        else
            echo "$appName deleted successfully"
        fi
    else
        echo "Application not present: $appToDelete"
    fi

}

appName="MindManager.app"
silent_app_quit "$appName"
delete_app "$appName"

appName="Mindjet MindManager.app"
silent_app_quit "$appName"
delete_app "$appName"


# Try to Forget the packages if we can find a match
for pkg in $(/usr/sbin/pkgutil --pkgs=com.mindjet.mindmanager.*); do
    echo "Forgetting package $pkg..."
    /usr/sbin/pkgutil --pkgs="$pkg" | /usr/bin/xargs /usr/bin/sudo /usr/sbin/pkgutil --forget
done

echo "$appName deletion complete"
