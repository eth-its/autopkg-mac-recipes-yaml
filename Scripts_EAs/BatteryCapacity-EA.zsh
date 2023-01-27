#!/bin/zsh
# shellcheck shell=bash

# Determine maximum battery capacity and state if degraded (under 80%)

capacity=$(system_profiler SPPowerDataType | sed -n -e 's/^.*Maximum Capacity: //p' | sed 's/\%//')

if [[ $capacity -lt 80 ]]; then
    echo "<result>$capacity - degraded</result>"
else
    echo "<result>$capacity</result>"
fi

exit 0