#!/bin/bash

#######################################################################
#
# Uninstall SeqMonk Script for Jamf Pro
# Note: this script's filename MUST end .sh for it to function
#
#######################################################################

# Inputted variables
appName="SeqMonk"

# kill SeqMonk
kill -9 "$(ps -A | grep -i seqmonk | grep -v grep | grep -v .sh | awk '{print $1}')"

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

echo "Application will be deleted: $appToDelete"
# Remove the application
[[ -d "${appToDelete}" ]] && /bin/rm -rf "${appToDelete}"

echo "Checking if $appName is actually deleted..."
if [[ -d "${appToDelete}" ]]; then
    echo "$appName failed to delete"
else
    echo "$appName deleted successfully"
fi

# Try to Forget the packages if we can find a match
# Loop through the remaining parameters
pkg="uk.ac.babraham.seqmonk"
echo "Forgetting package $pkg..."
/usr/sbin/pkgutil --pkgs | /usr/bin/grep -i "$pkg" | /usr/bin/xargs /usr/bin/sudo /usr/sbin/pkgutil --forget

echo "$appName deletion complete"
