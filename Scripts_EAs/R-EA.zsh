#!/bin/zsh
# shellcheck shell=bash

# R version detection extension attribute

version="None"
info_plist=/Library/Frameworks/R.framework/Versions/Current/Resources/Info.plist

if [ -f "$info_plist" ]; then
    version=$(/usr/bin/defaults read "$info_plist" CFBundleVersion)
fi
echo "<result>$version</result>"
exit 0