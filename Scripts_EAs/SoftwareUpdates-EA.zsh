#!/bin/zsh
# shellcheck shell=bash

# Check for whether there are any Software Updates available
result=$(/usr/libexec/PlistBuddy -c "Print :LastRecommendedUpdatesAvailable" /Library/Preferences/com.apple.SoftwareUpdate.plist 2>/dev/null)

echo "<result>$result</result>"
exit 0