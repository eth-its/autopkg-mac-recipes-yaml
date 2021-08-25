#!/bin/bash

# Read DetectX Results and report any discovered infections
# based on https://github.com/haircut/detectx-jamf/blob/master/EA-DetectX-Issues.py
# converted to bash

management_dir="/Library/Application Support/JAMF/Addons/DetectX"
result_plist="$management_dir/results.plist"

# convert to plist so bash can cope
if [[ -f "$result_plist" ]]; then
    # look for any issues
    issues_output=$(/usr/libexec/PlistBuddy -c "Print :infections:" "$result_plist" 2>/dev/null | sed -e '1d;$d' -e 's/^[ \t]*//')
else
    issues_output=""
fi

if [[ "$issues_output" == "" ]]; then
    issues_output="None"
fi

echo "<result>$issues_output</result>"

exit 0