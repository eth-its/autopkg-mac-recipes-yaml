#!/bin/zsh
# shellcheck shell=bash

: <<DOC 
Logitech Presentation Version - Jamf Pro Extension Attribute
by Graham Pugh

Checks installed version of Logitech Presentation software
DOC

# App version
lp_version=$( /usr/bin/defaults read "/Library/Application Support/Logitech.localized/Logitech Presentation.localized/Logitech Presentation.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null )


if [[ "$lp_version" != "" ]]; then
    result="$lp_version"
else
    result="None"
fi

echo "<result>$result</result>"