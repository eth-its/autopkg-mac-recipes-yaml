#!/bin/zsh
# shellcheck shell=bash

: <<DOC 
swiftDialog Version - Jamf Pro Extension Attribute
by Graham Pugh

Checks installed version of swiftDialog
DOC

# App version
version=$( /usr/bin/defaults read "/Library/Application Support/Dialog/Dialog.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null )"-"$( /usr/bin/defaults read "/Library/Application Support/Dialog/Dialog.app/Contents/Info.plist" CFBundleVersion 2>/dev/null )

if [[ "$version" != "" ]]; then
    result="$version"
else
    result="None"
fi

echo "<result>$result</result>"