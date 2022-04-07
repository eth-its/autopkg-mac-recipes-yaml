#!/bin/zsh
# shellcheck shell=bash

# Check for the presence of krb5.conf

if [[ -f "/etc/krb5.conf" ]]; then
    result="Installed"
else
    result="Not installed"
fi

echo "<result>$result</result>"
exit 0