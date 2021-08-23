#!/bin/sh
string_type=%VERSION_STRING_TYPE%
version_string=""
if [ -f "/Applications/%JSS_INVENTORY_NAME%/Contents/Info.plist" ]; then
    version_string=$(defaults read "/Applications/%JSS_INVENTORY_NAME%/Contents/Info.plist" $string_type)
fi
echo "<result>$version_string</result>"
exit 0