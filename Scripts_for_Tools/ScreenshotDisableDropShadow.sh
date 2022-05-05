#!/bin/sh

# https://themacbeginner.com/disable-drop-shadow-mac-os-screenshots/

current_user=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
if [[ $current_user != "root" && $current_user != "_"*  ]]; then
    sudo -u $current_user -i /usr/bin/defaults write com.apple.screencapture disable-shadow -bool TRUE
    sudo -u $current_user -i killall SystemUIServer
    echo "Set com.apple.screencapture disable-shadow and restarted UI server"
else
    echo "Not running script as no user found"
fi

