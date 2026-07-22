#!/bin/zsh

versionfile="/Applications/Ideashare.app/Contents/Frameworks/libideashare_data_projection_client.dylib"

if [[ -f "$versionfile" ]]; then
    version=$(grep -a 'productVersion' ${versionfile} | LC_ALL=C sed -e 's/.*versionInfo: .*V\(.*\)product.*/\1/')
else
    version="None"
fi

echo "<result>$version</result>"

exit 0