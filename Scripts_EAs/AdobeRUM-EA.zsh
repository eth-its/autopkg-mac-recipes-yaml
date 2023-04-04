#!/bin/zsh 
# shellcheck shell=bash

: <<DOC 
Adobe RUM Version - Jamf Pro Extension Attribute
by Graham Pugh

Checks installed version of Adobe RUM
DOC

rum="/usr/local/bin/RemoteUpdateManager"

if [[ -f "$rum" ]]; then
    version=$(/usr/local/bin/RemoteUpdateManager -h 2>/dev/null | head -n 1 | sed 's/RemoteUpdateManager version is : //')
else
    version="None"
fi

echo "<result>$version</result>"

exit 0