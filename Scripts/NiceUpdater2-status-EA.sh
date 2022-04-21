#!/bin/bash

# Read the last user interaction with the Nice Updater tool
result="Status unknown"
status_file="/Library/Scripts/nice_updater_status.txt"
if [[ -f "$status_file" ]]; then
    result=$(head -n 1 "$status_file")
fi

echo "<result>$result</result>"

exit 0