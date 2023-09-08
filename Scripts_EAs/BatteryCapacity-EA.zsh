#!/bin/zsh
# shellcheck shell=bash

# Determine maximum battery capacity and state if degraded (under 80%)
arch=$(/usr/bin/arch)

condition=$(system_profiler SPPowerDataType | grep "Condition:" | sed 's/.*Condition: //')

if [[ "$arch" == "arm64" ]]; then
    capacity=" ($(system_profiler SPPowerDataType | grep "Maximum Capacity:" | sed 's/.*Maximum Capacity: //')%)"
fi

if [[ ! $condition ]]; then
    echo "<result>No battery</result>"
else
    echo "<result>$condition</result>"
fi

exit 0