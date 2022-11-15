#!/bin/bash

# Based on a script posted in the MacAdmins Slack by Jon Lonergan

PlistBuddy="/usr/libexec/PlistBuddy"
loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
user_prefs="/Users/$loggedInUser/Library/Preferences/com.apple.sidebarlists.plist"
echo $user_prefs

if [[ ! "$4" ]]; then
    echo "ERROR: no servers entered"
    exit 1
fi

servers=("$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}")

killall cfprefsd
echo "Setting servers for $user_prefs"
echo "Removing previous entries..."
${PlistBuddy} -c "Delete favoriteservers" "$user_prefs"

echo "Creating new list..."
${PlistBuddy} -c "Add favoriteservers:Controller string CustomListItems" "$user_prefs"
${PlistBuddy} -c "Add favoriteservers:CustomListItems array" "$user_prefs"

for i in "${!servers[@]}"; do
    if [[ "${servers[$i]}" ]]; then
        echo "Adding to Favorite Servers: ${servers[$i]}..."
        ${PlistBuddy} -c "Add favoriteservers:CustomListItems:$i:Name string ${servers[$i]}" "$user_prefs"
        ${PlistBuddy} -c "Add favoriteservers:CustomListItems:$i:URL string ${servers[$i]}" "$user_prefs"
    fi
done

echo "Finalizing settings..."
killall cfprefsd
defaults read "$user_prefs" favoriteservers > /dev/null