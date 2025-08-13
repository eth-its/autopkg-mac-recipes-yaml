#!/bin/zsh
# shellcheck shell=bash

# Determine whether computer has Touch ID enabled

touchid_functionality=$(/usr/bin/bioutil -rs | grep "Biometrics functionality")

if [[ $touchid_functionality ]]; then
    if grep -q "auth       sufficient     pam_tid.so" /etc/pam.d/sudo_local ; then
        result="True"
    elif grep -q "auth       sufficient     pam_tid.so" /etc/pam.d/sudo ; then
        result="True"
    else
        result="False"
    fi
else
	result="Unsupported"
fi

echo "<result>$result</result>"

exit 0
