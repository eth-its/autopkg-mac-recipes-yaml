#!/bin/bash

#######################################################################
#
# Uninstall Microsoft Office 2016 / 2019 / 365
#
#######################################################################

# All the other parameters can be package IDs to delete
OfficeApps=( "Microsoft Excel" "Microsoft OneNote" "Microsoft Outlook" "Microsoft PowerPoint" "Microsoft Word" "Microsoft OneNote" "Microsoft AutoUpdate" "OneDrive" )

for appName in "${OfficeApps[@]}"; do
    if [[ $(pgrep -x "$appName") ]]; then
    	echo "Closing $appName"
    	osascript -e "quit app \"$appName\""
    	sleep 1

    	# double-check
    	count=0
    	while [[ $count -le 10 ]]; do
    		if [[ -z $(pgrep -x "$appName") ]]; then
    			echo "$appName closed."
    			break
    		else
    			 (( count=count+1 ))
    			sleep 1
    		fi
    	done
        if [[ $(pgrep -x "$appName") ]]; then
    	    echo "$appName failed to quit - killing."
    	    /usr/bin/pkill "$appName"
        fi
    fi
done

echo "Removing Microsoft Office applications..."

[[ -d "/Applications/Microsoft Excel.app" ]] && rm -rf "/Applications/Microsoft Excel.app"
[[ -d "/Applications/Microsoft Word.app" ]] && rm -rf "/Applications/Microsoft Word.app"
[[ -d "/Applications/Microsoft PowerPoint.app" ]] && rm -rf "/Applications/Microsoft PowerPoint.app"
[[ -d "/Applications/OneDrive.app" ]] && rm -rf "/Applications/OneDrive.app"
[[ -d "/Applications/Microsoft Outlook.app" ]] && rm -rf "/Applications/Microsoft Outlook.app"
[[ -d "/Applications/Microsoft OneNote.app" ]] && rm -rf "/Applications/Microsoft OneNote.app"
[[ -d "/Applications/Microsoft Teams.app" ]] && rm -rf "/Applications/Microsoft Teams.app"

echo "Removing Microsoft Office LaunchDaemons..."

[[ -f "/Library/LaunchDaemons/com.microsoft.office.licensingV2.helper.plist" ]] && rm -rf "/Library/LaunchDaemons/com.microsoft.office.licensingV2.helper.plist"
[[ -f "/Library/LaunchDaemons/com.microsoft.onedriveupdaterdaemon.plist" ]] && rm -rf "/Library/LaunchDaemons/com.microsoft.onedriveupdaterdaemon.plist"

echo "Removing Microsoft Office PrivilegedHelperTools..."

[[ -f "/Library/PrivilegedHelperTools/com.microsoft.office.licensingV2.helper" ]] && rm -rf "/Library/PrivilegedHelperTools/com.microsoft.office.licensingV2.helper"

echo "Removing Microsoft Office Preferences..."

[[ -f "/Library/Preferences/com.microsoft.office.licensingV2.plist" ]] && rm -rf "/Library/Preferences/com.microsoft.office.licensingV2.plist"

echo "Removing Microsoft Office licenses..."

/usr/local/bin/jamf policy -event Microsoft_Office_Unlicense_Volume
/usr/local/bin/jamf policy -event Microsoft_Office_Unlicense_O365

receipts="com.microsoft.package.Microsoft_Excel.app
com.microsoft.package.Microsoft_PowerPoint.app
com.microsoft.package.Microsoft_Word.app
com.microsoft.package.Microsoft_OneNote.app
com.microsoft.package.Microsoft_Outlook.app
com.microsoft.teams
com.microsoft.OneDrive
com.microsoft.package.Frameworks
com.microsoft.package.Proofing_Tools
com.microsoft.package.Fonts
com.microsoft.pkg.licensing.volume
com.microsoft.pkg.licensing"

# Loop through the remaining parameters
pkgutilcmd="/usr/sbin/pkgutil"
while read -r receipt; do
    if $pkgutilcmd --pkgs="${receipt}"; then 
        $pkgutilcmd --forget "${receipt}"
    fi
done <<< "${receipts}"

echo "Microsoft Office removal complete!"
echo
echo "Please note that Microsoft AutoUpdate is not removed as it is used by multiple applications in addition to Microsoft Office."
echo
