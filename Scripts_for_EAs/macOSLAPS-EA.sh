#!/bin/zsh 
# shellcheck shell=bash

: <<DOC 
macOSLAPS Version - Jamf Pro Extension Attribute
by Graham Pugh

Checks installed version of macOSLAPS
DOC

LAPS="/usr/local/laps/macOSLAPS"

if [[ -f "$LAPS" ]]; then
    macoslaps_version=$("$LAPS" -version)
else
    macoslaps_version="None"
fi

echo "<result>$macoslaps_version</result>"

exit 0