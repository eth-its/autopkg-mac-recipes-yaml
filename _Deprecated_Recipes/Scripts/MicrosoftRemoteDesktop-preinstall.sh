#!/bin/bash
## Script to remove version 8 of Microsoft Remote Desktop before installing version 10

# Check whether the new version was installed manually and has been put in the wrong place
if [[ -d "/Applications/Microsoft Remote Desktop/Microsoft Remote Desktop.app" ]]; then
    echo "Removing second installation of Microsoft Remote Desktop 10."
    rm -rf "/Applications/Microsoft Remote Desktop/Microsoft Remote Desktop.app"
fi

# Check whether old version of app is installed
if [[ -d "/Applications/Microsoft Remote Desktop.app" ]]; then
    echo "Existing installation of Microsoft Remote Desktop found."
    # Check version
    currentVersion=$( /usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "/Applications/Microsoft Remote Desktop.app/Contents/Info.plist" )
    echo "Current version of Microsoft Remote Desktop: ${currentVersion}"
    versionInt=$( echo ${currentVersion} | cut -f 1 -d'.' )
    # Remove it if it's less than version 10
    if [[ ${versionInt} -lt 10 ]]; then
        echo "Removing Microsoft Remote Desktop ${versionInt}."
        rm -rf "/Applications/Microsoft Remote Desktop.app"
    fi
fi

exit
# Do not write 'exit 0' as this could provide a false positive that a policy has installed successfully even if something went wrong.
