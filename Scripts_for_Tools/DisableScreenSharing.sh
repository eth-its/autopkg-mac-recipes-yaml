#!/bin/sh

# Disable screen sharing

defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool true

launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist