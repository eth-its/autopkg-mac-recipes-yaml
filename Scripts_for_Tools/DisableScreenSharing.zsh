#!/bin/zsh
# shellcheck shell=bash

: <<DOC
Script to disable screen sharing
DOC
/usr/bin/defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool true

launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null 