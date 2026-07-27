#!/bin/zsh

versionfile="/Applications/Ideashare.app/Contents/MacOS/IdeaShare"

if [[ -f "$versionfile" ]]; then
    version=$(grep -a 'res =.*V' ${versionfile}| LC_ALL=C sed -e 's/.*res =.*V//g'|LC_ALL=C sed -e 's/bool.*//')
else
    version="None"
fi

echo "<result>$version</result>"

exit 0