#!/bin/zsh
# shellcheck shell=bash

# Determine whether location services is enabled

screen_sharing=$(/usr/libexec/PlistBuddy -c "Print :com.apple.screensharing:Disabled" /var/db/launchd.db/com.apple.launchd/overrides.plist 2>/dev/null)

if [[ $screen_sharing == "true" ]]; then
    result="True"
else
    result="False"
fi

echo "<result>$result</result>"

exit 0