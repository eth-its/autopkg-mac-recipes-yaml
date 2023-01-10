#!/bin/zsh
# shellcheck shell=bash

: <<DOC
Writes the Affinity2.defaults file to /Library/Application Support/Serif

Required parameters:
4 - Designer Product Key
5 - Publisher Product Key
6 - Photo Product Key
7 - Licensed Email Account
8 - License Signature
9 - User Count
10 - License Expiry
DOC

defaults_file_path="/Library/Application Support/Serif"
/bin/mkdir -p "$defaults_file_path"
defaults_file="$defaults_file_path/Affinity2.defaults"

cat > "$defaults_file" <<EOF
{
    "designerProductKey": "$4",
    "disableCheckForUpdates": true,
    "disableEULA": true,
    "disableRegistration": true,
    "licenseExpiry": "${10}",
    "licensedTo": "$7",
    "photoProductKey": "$6",
    "publisherProductKey": "$5",
    "signature": "$8",
    "userCount": $9
}
EOF

/bin/chmod 644 "$defaults_file"
/usr/sbin/chown root:wheel "$defaults_file"

if [[ -f "$defaults_file" ]]; then
    echo "License file successfully written"
else
    echo "ERROR: License file not written"
    exit 1
fi
