#!/bin/zsh
# shellcheck shell=bash

# Write the silnite version to file

# variables
version="%version%"
silnite_dir="/Library/Application Support/ETHZ/silnite"
silnite_version_file="$silnite_dir/silnite-version.txt"

mkdir -p "$silnite_dir"

if echo "$version" > "$silnite_version_file"; then
    echo "Wrote silnite version $version to $silnite_version_file"
else
    echo "ERROR: could not write to version file"
    exit 1
fi
