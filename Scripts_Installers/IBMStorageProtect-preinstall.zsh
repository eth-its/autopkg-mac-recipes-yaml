#!/bin/zsh
# shellcheck shell=bash

# Remove existing installation(s) if it is in the Applications folder or a subfolder

appName="IBM Storage Protect"

# quit the app if running
pkill dsmj
pkill TSMToolsforAdministrators

# look for any existing certificates and move them out of the way
tempdir=/var/folders/tivoli-reinstall
certdir="/Library/Application Support/tivoli/tsm/client/ba/bin"
if [[ -d "$certdir" ]]; then
    mkdir -p $tempdir
    cp "$certdir/dsmcert.kdb" "$certdir/dsmcert.sth" "$certdir/dsmcert.idx" $tempdir
fi

# Now remove the app
echo "Removing application: ${appName}"

if [[ -d "/Applications/${appName}/${appName}.app" ]]; then
    jamf policy -event "IBM Storage Protect-uninstall"
fi
