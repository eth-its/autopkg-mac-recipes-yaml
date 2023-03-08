#!/bin/zsh
# shellcheck shell=bash

# Determine how long since the last restart

up_time=$(uptime | cut -d' ' -f4)

if [[ ! $up_time ]]; then
    echo "<result></result>"
else
    echo "<result>$up_time</result>"
fi

exit 0