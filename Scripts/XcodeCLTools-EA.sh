#!/bin/zsh
# shellcheck shell=bash

# Check for Command line tools

if xcode-select -p >/dev/null 2>&1; then
    result="Installed"
else
    result="Not installed"
fi

echo "<result>$result</result>"
exit 0