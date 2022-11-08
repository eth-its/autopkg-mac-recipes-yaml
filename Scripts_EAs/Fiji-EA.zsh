#!/bin/zsh
# shellcheck shell=bash

# Fiji version detection extension attribute
# Requires the adapted package provided by com.github.eth-its-recipes.pkg.Fiji

CFBundleVersion=""
if [ -f "/Library/Application Support/Fiji/AdaptedInfo.plist" ]; then
    CFBundleVersion=$(defaults read "/Library/Application Support/Fiji/AdaptedInfo.plist" CFBundleVersion)
else
    CFBundleVersion="None"
fi
echo "<result>$CFBundleVersion</result>"
exit 0
        