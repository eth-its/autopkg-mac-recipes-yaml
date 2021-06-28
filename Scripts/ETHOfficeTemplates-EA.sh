#!/bin/bash
## ETH_Templates_MSOffice version

version=$(/usr/bin/defaults read /Library/Preferences/ch.ethz.id.ETHTemplatesMSOffice version)

if [[ ! $version ]]; then
    version="None"
fi

echo "<result>$version</result>"

exit 0