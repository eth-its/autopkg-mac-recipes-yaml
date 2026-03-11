#!/bin/bash
set -x

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

# wait until the command file has started, and then finished
while [[ $(pgrep -f $command_file|wc -l) -eq 0 ]] ; do sleep 0.1 ; done 
while [[ $(pgrep -f $command_file|wc -l) -gt 0 ]] ; do sleep 1 ; done 

# if we can't see 'brew' anymore, the user has decided to remove homebrew - so we clean up a bit more
which brew >/dev/null ; brewthere=$?
if [[ $brewthere -eq 0 ]] ; then 
pkgutil --forget sh.brew.homebrew /
rm -rf /usr/local/Homebrew || true
rm -rf /opt/homebrew || true
fi

# stop caffeinating
kill "$caffeinatepid"