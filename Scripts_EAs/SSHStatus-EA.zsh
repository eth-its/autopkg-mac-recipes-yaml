#!/bin/zsh
# shellcheck shell=bash

# Determine whether SSH is enabled (Remote Login)

ssh_state=$(/bin/launchctl print system | grep sshd | grep enabled )

if [[ -z $ssh_state ]]; then
    result="Disabled"
else
    result="Enabled"
fi

echo "<result>$result</result>"

exit 0