#!/bin/zsh

versionfile="/Applications/ccp4-9/restore/restores.xml"

if [[ -f "$versionfile" ]]; then
    version=$(xmllint --xpath "//updates/update[last()]/id/text()" $versionfile)
else
    version="None"
fi

echo "<result>$version</result>"

exit 0