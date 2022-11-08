#!/bin/bash 

if pkgutil --pkgs=com.github.grahampugh.nice_updater; then
    nice_updater_version=$(pkgutil --pkg-info com.github.grahampugh.nice_updater | grep version | sed 's|version: ||' | cut -d. -f -3)
else
    nice_updater_version="None"
fi

echo "<result>$nice_updater_version</result>"

exit 0