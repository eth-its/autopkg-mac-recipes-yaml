#!/bin/zsh
# shellcheck shell=bash

: <<DOC
Writes the Affinity.defaults file to /Library/Application Support/Serif

Required parameters:
4 - Designer Product Key
5 - Publisher Product Key
6 - Photo Product Key
7 - Licensed Email Account
8 - License Signature
9 - User Count
DOC

defaults_file="/Library/Application Support/Serif/Affinity.defaults"

cat > "$defaults_file" <<EOF
{
    "designerProductKey": "$4",
    "disableCheckForUpdates": true,
    "disableEULA": true,
    "licensedTo": "$7",
    "photoProductKey": "$6",
    "publisherProductKey": "$5",
    "signature": "$8",
    "userCount": $9
}
EOF

if [[ -f "$defaults_file" ]]; then
    echo "License file successfully written"
else
    echo "ERROR: License file not written"
    exit 1
fi
