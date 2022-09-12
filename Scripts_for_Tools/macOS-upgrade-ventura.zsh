#!/bin/zsh
# shellcheck shell=bash

: <<DOC 
erase-install run script
by Graham Pugh
DOC

eraseinstall="/Library/Management/erase-install/erase-install.sh"

if [[ ! -f "$eraseinstall" ]]; then
    jamf policy -event "erase-install-install"
fi

/Library/Management/erase-install/erase-install.sh --os 13 --update --reinstall --cleanup-after-use --depnotify --current-user --beta --seed PublicSeed

