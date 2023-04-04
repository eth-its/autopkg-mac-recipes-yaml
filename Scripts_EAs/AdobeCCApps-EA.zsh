#!/bin/zsh 
# shellcheck shell=bash

: <<DOC 
Check if updates for Adobe CC Apps are available - Jamf Pro Extension Attribute
by Graham Pugh
DOC

# log file
loglocation="/Library/Management/ETHZ/Adobe"
logfile="$loglocation/RemoteUpdateManager.txt"

if [[ -f "$logfile" ]]; then
    if grep -q 'No new applicable Updates.' "$logfile"; then
        result="Up to date"
    elif grep -q 'Following Updates' "$logfile"; then
        result="Updates available"
    else 
        result="Unknown"
    fi
else
    result="RUM logfile missing"
fi

echo "<result>$result</result>"

exit 0