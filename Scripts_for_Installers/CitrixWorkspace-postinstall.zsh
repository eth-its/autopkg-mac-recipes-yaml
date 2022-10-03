#!/bin/zsh
# shellcheck shell=bash

# remove Citrix Workspace LaunchAgent
# originally from Owen Gallagher
# https://discussions.citrix.com/topic/400690-macos-prevent-workspacereceiver-from-starting-at-loginboot/

rm /Library/LaunchAgents/com.citrix.ReceiverHelper.plist