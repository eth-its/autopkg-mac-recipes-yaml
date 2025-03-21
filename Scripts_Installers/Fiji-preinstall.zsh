#!/bin/zsh
# shellcheck shell=bash

# Remove previous version of Fiji from /Applications

find /Applications -type d -name "Fiji*" -maxdepth 1 -exec rm -rf {} +

# The internal updater requires the Xcode command line tools (for git)
if xcode-select -p >/dev/null 2>&1; then
    result="Installed"
else
    result="Not installed"
fi

if [[ "$result" == "Not installed" ]]; then
   echo "The Xcode Command Line Tools are required to use Fiji. Installing now."
   jamf policy -event XcodeCLTools-install
fi
