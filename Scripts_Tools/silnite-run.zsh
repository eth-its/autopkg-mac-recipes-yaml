#!/bin/zsh
# shellcheck shell=bash

# Run silnite 

# variables
silnite_bin="/usr/local/bin/silnite"
silnite_dir="/Library/Application Support/ETHZ/silnite"
silnite_output_file="$silnite_dir/silnite.json"


if [[ -f "$silnite_bin" ]]; then
    mkdir -p "$silnite_dir"
    if "$silnite_bin" amj > "$silnite_output_file"; then
        echo "silnite ran and outputted to $silnite_output_file"
    else
        echo "ERROR: silnite exited with error $?"
    fi
else
    # clean up any relics
    echo "silnite is not installed"
    if [[ -d "$silnite_dir" ]]; then
        rm -rf "$silnite_dir"
    fi
    old_silnite_dir="/Users/Shared/ETHZ/silnite"
    if [[ -d "$old_silnite_dir" ]]; then
        rm -rf "$old_silnite_dir"
        [[ $(/bin/ls -A "/Users/Shared/ETHZ") ]] || rm -rf "/Users/Shared/ETHZ"
    fi
fi


