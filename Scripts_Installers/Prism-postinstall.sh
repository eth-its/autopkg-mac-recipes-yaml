#!/bin/bash

# Writes the silent activation xml file for Prism.

serial_number='%license_key%'

config_path="/Library/Application Support/GraphPad/Prism"
config_file="$config_path/prism-config.xml"

config_contents="<configuration><silent-activation>true</silent-activation><serial-number>$serial_number</serial-number><check-for-updates>false</check-for-updates><measure-units>metric</measure-units><email-collection>disable</email-collection></configuration>"

/bin/mkdir -p "$config_path"
echo "$config_contents" > "$config_file"

if [[ -f "$config_file" ]]; then
    echo "Contents of '$config_file':"
    cat "$config_file"
else
    echo "ERROR: Could not create silent activation file"
    exit 1
fi
