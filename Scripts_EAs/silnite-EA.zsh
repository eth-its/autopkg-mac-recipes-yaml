#!/bin/zsh
# shellcheck shell=bash

# Get the silnite version from file

# variables
silnite_dir="/Library/Application Support/ETHZ/silnite"
silnite_version_file="$silnite_dir/silnite-version.txt"

version=""
if [[ -f "$silnite_version_file" ]]; then
    version=$(/bin/cat "$silnite_version_file")
fi

# clean up any relics
# old_silnite_dir="/Users/Shared/ETHZ/silnite"
# if [[ -d "$old_silnite_dir" ]]; then
#     rm -rf "$old_silnite_dir"
#     [[ $(/bin/ls -A "/Users/Shared/ETHZ") ]] || rm -rf "/Users/Shared/ETHZ"
# fi

result="None"

if [[ $version ]]; then
    result="$version"
fi

echo "<result>$result</result>"

exit 0