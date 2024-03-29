#!/bin/zsh
# shellcheck shell=bash

# variables
silnite_bin="/usr/local/bin/silnite"
silnite_dir="/Library/Application Support/ETHZ/silnite"

# remove the silnite binary
if [[ -f "$silnite_bin" ]]; then
    if rm -f "$silnite_bin"; then
        echo "silnite was deleted"
    else
        echo "ERROR: silnite was not deleted"
    fi
else
    echo "silnite not found"
fi

# remove the output files
if  [[ -d "$silnite_dir" ]]; then
    if rm -rf "$silnite_dir"; then
        echo "silnite output directory was deleted"
    else
        echo "ERROR: silnite output directory was not deleted"
    fi
else
    echo "silnite output directory not found"
fi

# clean up any relics
old_silnite_dir="/Users/Shared/ETHZ/silnite"
if [[ -d "$old_silnite_dir "]]; then
    rm -rf "$old_silnite_dir"
    [[ $(/bin/ls -A "/Users/Shared/ETHZ") ]] || rm -rf "/Users/Shared/ETHZ"
fi

