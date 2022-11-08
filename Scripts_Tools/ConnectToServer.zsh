#!/bin/zsh

PlistBuddy="/usr/libexec/PlistBuddy"
loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
user_prefs="/Users/$loggedInUser/Library/Preferences/com.apple.sidebarlists.plist"

share_url="$1"
share_name="$2"

## Add the new server entry for current logged in user
"$PlistBuddy" -c "Add :favoriteservers:CustomListItems:0 dict" "$user_prefs"
"$PlistBuddy" -c "Add :favoriteservers:CustomListItems:0:Name string $share_name" "$user_prefs"
"$PlistBuddy" -c "Add :favoriteservers:CustomListItems:0:URL string $share_url" "$user_prefs"