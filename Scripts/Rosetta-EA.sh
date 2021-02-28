#!/bin/bash

: << DOC
EA to determine whether Rosetta is installed. 
Possible results:
"installed"    - arm64 Mac - Rosetta is installed
"missing"      - arm64 Mac - Rosetta is not installed
"ineligible" - Intel Mac - Rosetta cannot be installed
DOC

# is this an ARM Mac?
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    # is rosetta 2 installed?
    if [[ -f "/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist" ]]; then
        result="installed"
    else
        result="missing"
    fi
else
    result="ineligible"
fi

echo "<result>$result</result>"
