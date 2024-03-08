#!/bin/zsh
# shellcheck shell=bash

# Determine maximum battery capacity and state if degraded (under 80%)
arch=$(/usr/bin/arch)

condition=$(system_profiler SPPowerDataType | grep "Condition:" | sed 's/.*Condition: //')

if [[ "$arch" == "arm64" ]]; then
    capacity=" ($(system_profiler SPPowerDataType | grep "Maximum Capacity:" | sed 's/.*Maximum Capacity: //'))"
elif [[ $condition ]]; then
    designcapacity=$(ioreg -l -w0 | grep "\"DesignCapacity\" =" | sed 's/.*= //')
    maxcapacity=$(ioreg -l -w0 | grep "\"MaxCapacity\" =" | sed 's/.*= //')
    capacity=" ($(($maxcapacity*100/$designcapacity))%)"
fi

if [[ ! $condition ]]; then
    echo "<result>Normal (No battery)</result>"
else
    echo "<result>$condition$capacity</result>"
fi

exit 0