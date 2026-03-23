#!/bin/bash

: <<DOC
SPSS Statistics 28+ are installed into a folder named "IBM SPSS Statistics".
To continue to allow multiple versions to be installed concurrently, this script
moves the folder to "IBM SPSS Statistics MAJOR_VERSION".
DOC

app_path=NOTSET
if [[ -d "/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app" ]]; then app_path="/Applications/IBM SPSS Statistics/IBM SPSS Statistics.app" ; 
elif [[ -d "/Applications/IBM SPSS Statistics/SPSS Statistics.app" ]]; then app_path="/Applications/IBM SPSS Statistics/SPSS Statistics.app" ;
else echo "No existing installation present within '/Applications/IBM SPSS Statistics'" ; exit 0 ; fi 


if [[ app_path != "NOTSET" ]]; then
    echo "Moving IBM SPSS Statistics app folder"
    # check the actual version of the app inside the folder
    installed_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$app_path/Contents/Info.plist" | cut -d. -f1)

    if ! mv "/Applications/IBM SPSS Statistics" "/Applications/IBM SPSS Statistics $installed_version"; then
        echo "ERROR: Failed to move folder"
        exit 1
    else
        echo "'/Applications/IBM SPSS Statistics $installed_version' successfully created"
    fi
else
    echo "No existing installation present within '/Applications/IBM SPSS Statistics'"
fi
