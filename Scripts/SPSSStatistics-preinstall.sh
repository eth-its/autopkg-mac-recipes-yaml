#!/bin/bash

: <<DOC
SPSS Statistics 28+ are installed into a folder named "IBM SPSS Statistics".
To continue to allow multiple versions to be installed concurrently, this script
moves the folder to "IBM SPSS Statistics MAJOR_VERSION".
DOC


if [[ -d "/Applications/IBM SPSS Statistics/SPSS Statistics.app" ]]; then
    echo "Moving IBM SPSS Statistics app folder"
    # check the actual version of the app inside the folder
    installed_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "/Applications/IBM SPSS Statistics/SPSS Statistics.app/Contents/Info.plist" | cut -d. -f1)

    if ! mv "/Applications/IBM SPSS Statistics" "/Applications/IBM SPSS Statistics $installed_version"; then
        echo "ERROR: Failed to move folder"
        exit 1
    else
        echo "'/Applications/IBM SPSS Statistics $installed_version' successfully created"
    fi
else
    echo "No existing installation present within '/Applications/IBM SPSS Statistics'"
fi
