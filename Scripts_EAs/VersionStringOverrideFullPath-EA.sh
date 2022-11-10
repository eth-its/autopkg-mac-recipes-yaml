#!/bin/sh
string_type=%VERSION_STRING_TYPE%
path_to_plist=%VERSION_PLIST%
version_string="None"
if [ -f "%VERSION_PLIST_PATH%" ]; then
    version_string=$(defaults read "%VERSION_PLIST_PATH%" $string_type)
fi
echo "<result>$version_string</result>"
exit 0