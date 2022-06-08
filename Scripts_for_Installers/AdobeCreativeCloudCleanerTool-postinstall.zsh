#!/bin/zsh
# shellcheck shell=bash

## postinstall script to remove CCDA applications

# remove any existing version of the tool
echo "Moving the CC Cleaner app to Utilities in case users need it later"
rm -rf /Applications/Utilities/Adobe\ Creative\ Cloud\ Cleaner\ Tool.app ||:
mv /Applications/Adobe\ Creative\ Cloud\ Cleaner\ Tool.app /Applications/Utilities/Adobe\ Creative\ Cloud\ Cleaner\ Tool.app

# run the cleaner tool to remove EVERYTHING!
echo "Running the CC Cleaner app with 'removeAll=All' option"
/Applications/Utilities/Adobe\ Creative\ Cloud\ Cleaner\ Tool.app/Contents/MacOS/Adobe\ Creative\ Cloud\ Cleaner\ Tool --removeAll=All --eulaAccepted=1

# remove Acrobat DC and Lightroom since the cleaner tool fails to do so
echo "Removing Acrobat DC if present"
[[ -d /Applications/Adobe\ Acrobat\ DC ]] && jamf policy -event "Adobe Acrobat DC-uninstall" ||:

echo "Removing Lightroom if present"
[[ -d /Applications/Adobe\ Lightroom\ CC ]] && rm -rf /Applications/Adobe\ Lightroom\ CC ||:

echo "Removing XD if present"
[[ -d /Applications/Adobe\ XD ]] && rm -rf /Applications/Adobe\ XD ||:

echo "Removing any Adobe 202x apps if present"
find /Applications -name "Adobe*202*" -maxdepth 1 -exec rm -rf {} +

echo "Removing any Adobe 2020 apps if present - second pass"
find /Applications -name "Adobe*202*" -maxdepth 1 -exec rm -rf {} +

echo "Removing Maxon Cinema 4D folder which is installed by Adobe After Effects CC 202x"
find /Applications -name "Maxon Cinema 4D*" -maxdepth 1 -exec rm -rf {} +

# delete the folders that remain
echo "Removing Adobe Application Manager if present"
[[ -d /Applications/Utilities/Adobe\ Application\ Manager ]] && rm -rf /Applications/Utilities/Adobe\ Application\ Manager ||:

echo "Removing Adobe Installers folder if present"
[[ -d /Applications/Utilities/Adobe\ Installers ]] && rm -rf /Applications/Utilities/Adobe\ Installers ||:

echo "Removing Adobe Application Support folder"
[[ -d /Library/Application\ Support/Adobe ]] && rm -rf /Library/Application\ Support/Adobe ||:

# also remove the current user's Adobe folder
# (warning! this could break Acrobat Reader DC and/or Flash Player - might need to uninstall those too)
current_user=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')
echo "Removing Adobe Application Support folder in $current_user home directory"
[[ -d /Users/$current_user/Library/Application\ Support/Adobe ]] && rm -rf /Users/$current_user/Library/Application\ Support/Adobe ||:

echo "Finished cleaning up Adobe CC applications"
