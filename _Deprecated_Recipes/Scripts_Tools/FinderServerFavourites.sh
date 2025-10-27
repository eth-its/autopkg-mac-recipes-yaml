#!/bin/bash

: <<DOC
Jamf Pro Launcher Script for FinderServerFavourites.py

Usage:
Use Parameter 4 to specify "add" or "remove".
Use Parameters 5-11 to specify servers to add or remove.
DOC

workdir="/Library/Management/FinderServerFavourites"

# bundled python directory
relocatable_python_path="$workdir/Python.framework/Versions/Current/bin/python3"

# obtain arguments

# set parameters
current_user=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')
current_user_id="$(echo 'show State:/Users/ConsoleUser' | scutil | awk '($1 == "UID") { print $NF; exit }')"

# print settings
echo "User: $current_user"
echo "Mode: $4"
echo "Servers: $5 $6 $7 $8 $9 ${10} ${11}"

# ensure the file exists
/bin/launchctl asuser "${current_user_id}" sudo -u "$current_user" -i touch "/Users/$current_user/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.FavoriteServers.sfl2"

# now call the script
/bin/launchctl asuser "${current_user_id}" sudo -u "$current_user" -i "$relocatable_python_path" "$workdir/FinderServerFavourites.py" --user "$current_user" --mode "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}"
