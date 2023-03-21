#!/bin/zsh 
# shellcheck shell=bash

: <<DOC 
Check if updates for Adobe CC Apps are available - Jamf Pro Extension Attribute
by Graham Pugh
DOC

rum="/usr/local/bin/RemoteUpdateManager"

if [[ -f "$rum" ]]; then
    output=$(/usr/local/bin/RemoteUpdateManager --action=list 2>/dev/null)
    exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        if grep -q 'No new applicable Updates.' <<< "$output"; then
            result="Up to date"
        elif grep -q 'Following Updates' <<< "$output"; then
            result="Updates available"
        else 
            result="Unknown"
        fi
    elif [[ $exit_code -eq 1 ]]; then
        result="RUM execution error"
    fi
else
    result="RUM not installed"
fi

echo "<result>$result</result>"

exit 0