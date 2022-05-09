#!/bin/zsh
# shellcheck shell=bash

: <<DOC
Script to disable screen sharing
DOC
defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool true

launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist