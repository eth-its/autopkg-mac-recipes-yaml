#!/bin/bash

: <<DOC
Jamf Pro Launcher Script for FinderServerFavourites.py

Usage:
Use Parameter 4 to specify "add" or "remove".
Use Parameters 5-11 to specify servers to add or remove.
DOC

workdir="/Library/Management/FinderServerFavourites"

if [[ ! -f "$workdir/FinderServerFavourites.py" ]]; then
    # FinderServerFavourites not installed, run trigger to install
    jamf policy -event FinderServerFavourites-install
fi

# bundled python directory
relocatable_python_path="$workdir/Python.framework/Versions/Current/bin/python3"

# obtain arguments

# set parameters
user=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')

# print settings
echo "User: $user"
echo "Mode: $4"
echo "Servers: $5 $6 $7 $8 $9 ${10} ${11}"

# now call the script
"$relocatable_python_path" "$workdir/FinderServerFavourites.py" "$user" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}"
