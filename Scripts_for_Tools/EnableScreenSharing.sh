#!/bin/sh

# Enable screen sharing

defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false

launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist