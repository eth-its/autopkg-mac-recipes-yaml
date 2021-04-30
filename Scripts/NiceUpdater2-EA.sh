#!/bin/bash 

nice_updater_version=$(pkgutil --pkg-info com.github.grahampugh.nice_updater | grep version | sed 's|version: ||' | cut -d. -f -3)

if [[ "${nice_updater_version}" == *"No receipt"* ]]; then 
    nice_updater_version=""
fi

echo "<result>$nice_updater_version</result>"

exit 0