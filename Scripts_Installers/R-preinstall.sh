#!/bin/bash

# ensure XCode Command Line tools are installed before installation starts
if xcode-select -p >/dev/null 2>&1; then
    echo "Xcode CLI Installed, proceding"
else
    echo "XCode CLI not installed, installing"
    jamf policy -event "XcodeCLTools-install"
fi