#!/bin/bash

filter=%EXTENSION_ATTRIBUTE_VALUE%

temp_file="/Users/Shared/jamf_java_versions_extension_attribute_check.plist"
rm -f "$temp_file" ||:


if [[ $filter == "8" ]]; then 
    filter_name="1.8"
elif [[ $filter == "11" ]]; then
    filter_name="11"
else
    latest_jvm="None"
fi

if [[ $filter_name ]]; then
    # get the JVM version using java_home
    latest_jvm=$(/usr/libexec/java_home -X -v $filter_name | grep -A2 -m3 AdoptOpenJDK | tail -n 1 | sed 's|<[^>]*>||g' | sed 's|^[[:space:]]*||' | grep "$filter_name." )
else
    latest_jvm="None"
fi

[[ $latest_jvm == "" ]] && latest_jvm="None"

echo "<result>$latest_jvm</result>"

exit 0