#!/bin/zsh
# shellcheck shell=bash

# Remove previous version of Fiji from /Applications

if [ -d "$3/Applications/Fiji.app" ]; then
   rm -rf "$3/Applications/Fiji.app"
fi

# The internal updater requires the Xcode command line tools (for git)
jamf policy -event Xcode_Command_Line_Tools-install
