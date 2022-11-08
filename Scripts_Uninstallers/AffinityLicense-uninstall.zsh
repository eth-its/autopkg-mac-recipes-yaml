#!/bin/zsh
# shellcheck shell=bash

# Affinity License uninstaller
defaults_file_path="/Library/Application Support/Serif"

if /bin/ls /Applications/Affinity\ * &> /dev/null ; then
    echo "One or more Affinity products still installed - leaving license file in place"
    exit 0
fi

if [[ -d "$defaults_file_path" ]]; then 
    /bin/rm -rf "$defaults_file_path"
    echo "No Affinity products remaining - Affinity license file removed"
fi
