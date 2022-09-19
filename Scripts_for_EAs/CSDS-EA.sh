#!/bin/bash

# CSDS version finder extension attribute

version="None"

# look for the CSDS folder
if [[ -d "/Applications/CSDS" ]]; then
    # now look for the major version
    if discovery_folder=$(find /Applications/CSDS -name "Discovery_*" -maxdepth 1 -type d 2> /dev/null); then
        major_version=$(basename "$discovery_folder" | cut -d_ -f2)
        # now look for the version_info file in the GOLD folder
        version_file="/Applications/CSDS/Discovery_$major_version/GOLD/version_info"
        if [[ -f "$version_file" ]]; then
            # now read the version from the file
            version=$(cat "$version_file" | cut -d" " -f3)
        fi
    fi
fi

echo "<result>$version</result>"

exit 0