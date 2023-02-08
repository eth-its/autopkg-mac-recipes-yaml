#!/bin/zsh
# shellcheck shell=bash

# postinstall to prevent Dell Display and Peripheral Manager updates
# in the DDPM_settings.json contents based on advice at:
# https://www.dell.com/community/Monitors/DDM-disable-updates-with-silent-install/m-p/7776513
# https://www.dell.com/community/Monitors/macOS-disable-DDM-autostart/td-p/8077681

# path to config.json
settingsfile="/Applications/DDPM/DDPM_settings.json"

echo "Check that the file is present..."
if [[ ! -f "$settingsfile" ]]; then
    echo "No settings file present; aborting"
    exit
fi

echo "Checking live updates status..."
if /usr/bin/grep -q "\"Enabled_Live_Update\" : false" "$settingsfile"; then
    # nothing to do
    echo "Updates in $settingsfile already disabled."
    exit 0
fi

if /usr/bin/grep -q "\"Enabled_Live_Update\" :" "$settingsfile"; then
    # need to change this line
    echo "Setting line to false incorrect settings..."
    if ! sed -i.tmp.json $'/"Enabled_Live_Update" : true/c\\\n        "Enabled_Live_Update" : false\,\n' "$settingsfile"; then
        echo "sed replacement error"
        exit 1
    fi
    # remove the temp backup file (not required)
    rm -f "$settingsfile.tmp.json"
fi
if /usr/bin/grep -q "\"Enabled_Live_Update\" : false" "$settingsfile"; then
    echo "Updates in $settingsfile now disabled."
else
    echo "ERROR: replacement did not work"
fi


