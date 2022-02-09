#!/bin/zsh
# shellcheck shell=bash

# Check for Command line tools
if xcode_location=$(xcode-select -p 2>/dev/null); then
    if [[ -d "$xcode_location" ]]; then
        echo "Xcode Command Line Tools installed - removing..."
        rm -Rf "$xcode_location"
    else
        echo "An error occurred"
        exit 1
    fi
else
    echo "Xcode Command Line Tools Not installed - nothing to do"
fi
