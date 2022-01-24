#!/bin/bash

# postinstall to remove any old versions of Mindjet MindManager

# Remove the old Mindjet MindManager app
appName="Mindjet MindManager"
appToDelete="/Applications/$appName.app"
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

