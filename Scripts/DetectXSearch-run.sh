#!/bin/bash

# Run DetectX Search
# based on https://github.com/haircut/detectx-jamf/blob/master/run-detectx-search.py

management_dir="/Library/Application Support/JAMF/Addons/DetectX"

[[ -d "$management_dir" ]] || mkdir -p "$management_dir"
result_json="$management_dir/results.json"
result_plist="$management_dir/results.plist"

# run the detectx search command
/Applications/DetectX\ Swift.app/Contents/MacOS/DetectX\ Swift search -aj "$result_json"

# convert the json to plist
plutil -convert xml1 -r -o "$result_plist" "$result_json"

# pretty print to stdout
if [[ -f "$result_plist" ]]; then
    plutil -p "$result_plist"
else
    echo "Error: no output from DetectX search command"
    exit 1
fi
