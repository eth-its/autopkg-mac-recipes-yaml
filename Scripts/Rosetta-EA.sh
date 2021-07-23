#!/bin/bash

: << DOC
EA to determine whether Rosetta is installed. 
Possible results:
"installed"    - arm64 Mac - Rosetta is installed
"missing"      - arm64 Mac - Rosetta is not installed
"ineligible" - Intel Mac - Rosetta cannot be installed
DOC

# is this an ARM Mac?
if [[ "$(/usr/bin/arch)" == "arm64" ]]; then
    # is Rosetta 2 installed?
    if /usr/bin/pgrep oahd >/dev/null 2>&1 ; then
        result="installed"
    else
        result="missing"
    fi
else
    result="ineligible"
fi

echo "<result>$result</result>"
