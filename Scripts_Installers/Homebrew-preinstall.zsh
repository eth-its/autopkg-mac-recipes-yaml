#!/bin/zsh
# shellcheck shell=bash

## Script to ensure XCode Command Line tools are installed before Homebrew installation
if xcode-select -p >/dev/null 2>&1; then
    echo "Xcode CLI Installed, proceding"
else
    echo "XCode CLI not installed, installing"
    jamf policy -event "XcodeCLTools-install"
fi

