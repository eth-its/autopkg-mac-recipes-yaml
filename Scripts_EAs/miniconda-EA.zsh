#!/bin/zsh
# shellcheck shell=bash

# miniconda3 version detection extension attribute

CFBundleVersion=""
if [ -d "/opt/miniconda3" ]; then
    CFBundleVersion=$(/usr/bin/defaults read /var/db/receipts/io.continuum.pkg.prepare_installation.plist PackageVersion|tr -d 'py')
else
    CFBundleVersion="None"
fi
echo "<result>${CFBundleVersion}</result>"
exit 0