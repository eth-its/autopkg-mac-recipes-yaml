#!/bin/zsh
# shellcheck shell=bash

# Check for whether there are any Software Updates available

if /usr/libexec/PlistBuddy -c "Print :RecommendedUpdates:0" /Library/Preferences/com.apple.SoftwareUpdate.plist 2>/dev/null; then
    result="true"
else
    result="false"
fi

echo "<result>$result</result>"
exit 0