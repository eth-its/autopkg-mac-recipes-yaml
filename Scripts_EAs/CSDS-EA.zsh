#!/bin/zsh
# shellcheck shell=bash

# CSDS version finder extension attribute

version="None"

# look for the CSDS folder
if [[ -d "/Applications/CSDS" ]]; then
    # now look for the version_info file in the GOLD folder
    version_file="/Applications/CSDS/Discovery_%MAJOR_VERSION%/GOLD/version_info"
    if [[ -f "$version_file" ]]; then
        # now read the version from the file
        version=$(cat "$version_file" | cut -d" " -f3)
    fi
fi

echo "<result>$version</result>"

exit 0