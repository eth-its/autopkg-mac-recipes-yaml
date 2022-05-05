#!/bin/bash

# Determine whether location services is enabled

screen_sharing=$(/usr/bin/defaults read /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled 2>/dev/null)

if [[ $screen_sharing  ]]; then
    result="True"
else
    result="False"
fi

echo "<result>$result</result>"

exit 0