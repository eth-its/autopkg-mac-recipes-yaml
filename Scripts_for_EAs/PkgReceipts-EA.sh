#!/bin/bash

## EA for getting the version from a package receipt

temp_file="/tmp/%PKG_ID%.plist"

/usr/sbin/pkgutil --pkg-info-plist "%PKG_ID%" > "$temp_file"
version=$(/usr/bin/defaults read "$temp_file" pkg-version)
rm "$temp_file" ||:

if [[ ! $version ]]; then
    version="None"
fi

echo "<result>$version</result>"

exit 0