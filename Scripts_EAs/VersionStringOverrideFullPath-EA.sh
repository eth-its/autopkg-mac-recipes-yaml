#!/bin/bash
string_type="%VERSION_STRING_TYPE%"
path_to_plist="%VERSION_PLIST%"
version_string="None"
if [[ -f "$path_to_plist" ]]; then
    version_string=$(/usr/bin/defaults read "$path_to_plist" $string_type)
fi
echo "<result>$version_string</result>"
exit 0