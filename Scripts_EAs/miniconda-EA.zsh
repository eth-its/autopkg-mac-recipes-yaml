#!/bin/zsh
# shellcheck shell=bash

# miniconda3 version detection extension attribute

CFBundleVersion=""
if [ -f "/opt/miniconda3" ]; then
    CFBundleVersion=$(defaults read /var/db/receipts/io.continuum.pkg.prepare_installation.plist PackageVersion)
else
    CFBundleVersion="None"
fi
echo "<result>$CFBundleVersion</result>"
exit 0