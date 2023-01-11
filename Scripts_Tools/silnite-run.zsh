#!/bin/zsh
# shellcheck shell=bash

# Run silnite 

# variables
silnite_bin="/usr/local/bin/silnite"
silnite_dir="/Users/Shared/ETHZ/silnite"
silnite_output_file="$silnite_dir/silnite.json"

mkdir -p "$silnite_dir"

if [[ -f "$silnite_bin" ]]; then
    if "$silnite_bin" amj > "$silnite_output_file"; then
        echo "silnite ran and outputted to $silnite_output_file"
    else
        echo "ERROR: silnite exited with error $?"
    fi
else
    echo "silnite is not installed"
    exit 1
fi


