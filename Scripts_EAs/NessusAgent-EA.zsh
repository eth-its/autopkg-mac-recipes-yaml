#!/bin/zsh
# shellcheck shell=bash

# Check for Nessus Agent version
result="None"
version=$(/Library/NessusAgent/run/sbin/nessuscli -v | awk '/nessuscli/{print $4}')

if [[ "$version" ]]; then
    result="$version"
fi

echo "<result>$result</result>"
exit 0