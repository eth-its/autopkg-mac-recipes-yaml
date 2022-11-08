#!/bin/zsh 
# shellcheck shell=bash

: <<DOC 
erase-install Version - Jamf Pro Extension Attribute
by Graham Pugh

Checks installed version of erase-install
DOC

eraseinstall="/Library/Management/erase-install/erase-install.sh"

if [[ -f "$eraseinstall" ]]; then
    eraseinstall_version=$(grep -e "^version\=\"*\.*\"" "$eraseinstall" | sed 's|"||g' | cut -d= -f2)
else
    eraseinstall_version="None"
fi

echo "<result>$eraseinstall_version</result>"

exit 0