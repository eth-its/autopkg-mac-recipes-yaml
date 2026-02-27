#!/bin/bash

# get console user so we can run the script as that user
consoleuser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')

# location of temporary command file so that we can open a terminal to run the script
command_file="/tmp/Uninstall_Homebrew.command"

# keep the system alive while it's running
caffeinate -d -i -m -u &
caffeinatepid=$!

# write the command file whiich we will run
echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)" -f' > "$command_file"
chmod +x "$command_file"

# run the command file as the console user
sudo -u $consoleuser open "$command_file"

# stop caffeinating
kill "$caffeinatepid"