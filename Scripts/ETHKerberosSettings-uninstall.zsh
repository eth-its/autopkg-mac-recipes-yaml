#!/bin/zsh
# shellcheck shell=bash

# Check for krb5.conf
kerberos_file="/etc/krb5.conf"
if [[ -f "$kerberos_file" ]]; then
    echo "ETH Kerberos Settings installed - removing..."
    rm -f "$kerberos_file"
else
    echo "ETH Kerberos Settings not installed - nothing to do"
fi
