#!/bin/zsh

if [[ -d /Applications/NoMachine.app ]] ; then 
jamf policy -event "NoMachine-uninstall"
fi

exit 0