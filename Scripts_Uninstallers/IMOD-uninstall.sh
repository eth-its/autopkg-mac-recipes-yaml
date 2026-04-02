#!/bin/bash
# get console user so we can run the script as that user
consoleuser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')

# keep the system alive while it's running
caffeinate -d -i -m -u &
caffeinatepid=$!

# remove the entire application directory
rm -rf /Applications/IMOD/
pkgutil --forget edu.colorado.bio3d.IMOD / 

kill "$caffeinatepid"
exit 0