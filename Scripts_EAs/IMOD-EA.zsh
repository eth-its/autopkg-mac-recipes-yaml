#!/bin/zsh
# shellcheck shell=bash

# IMOD version detection extension attribute

CFBundleVersion=""
if [ -d "/Applications/IMOD" ]; then
    CFBundleVersion=$(cat /Applications/IMOD/VERSION)
else
    CFBundleVersion="None"
fi
echo "<result>${CFBundleVersion}</result>"
exit 0