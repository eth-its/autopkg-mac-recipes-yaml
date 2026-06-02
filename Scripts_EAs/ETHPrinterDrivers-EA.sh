#!/bin/bash
version=$(defaults read /var/db/receipts/%PKG_ID%.plist ProductVersion)
if [[ ! $version ]]; then
    version="None"
fi

echo "<result>$version</result>"
exit 0