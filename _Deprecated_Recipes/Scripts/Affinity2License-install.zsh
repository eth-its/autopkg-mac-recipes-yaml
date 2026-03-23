#!/bin/zsh
# shellcheck shell=bash

: <<DOC
Writes the Affinity2.defaults file to /Library/Application Support/Serif

Required parameters:
4 - Product Key
5 - Licensed Email Account
6 - License Signature1
7 - License Signature2
8 - License Expiry
9 - User Count

DOC

defaults_file_path="/Library/Application Support/Serif"
/bin/mkdir -p "$defaults_file_path"
defaults_file="$defaults_file_path/Affinity2.defaults"

cat > "$defaults_file" <<EOF
{
    "designerProductKey": "",
    "disableCheckForUpdates": true,
    "disableCrashReports": false,
    "disableEULA": true,
    "disableLinkThirdPartyCloud": false,
    "disableRegistration": true,
    "enableDWG": false,
    "enableHWAccelByDefault": true,
    "licenceExpiry": "$8",
    "licensedTo": "$5",
    "openAssetCredentials": [],
    "photoProductKey": "",
    "publisherProductKey": "",
    "signature": "$6",
    "signature2": "$7",
    "universalProductKey": "$4",
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
