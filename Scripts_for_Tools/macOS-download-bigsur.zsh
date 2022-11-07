#!/bin/zsh
# shellcheck shell=bash

: <<DOC 
erase-install run script
by Graham Pugh
DOC

eraseinstall="/Library/Management/erase-install/erase-install.sh"

jamf policy -event "erase-install-install"

/Library/Management/erase-install/erase-install.sh --os 11 --update --move --cleanup-after-use --depnotify --current-user

