#!/bin/bash
pkgutilcmd="/usr/sbin/pkgutil"
version=$($pkgutilcmd --pkg-info %PKG_ID% | grep version: | sed 's|version: ||')
if [[ ! $version ]]; then
    version="None"
fi

echo "<result>$version</result>"
exit 0