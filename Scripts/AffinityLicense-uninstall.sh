#!/bin/bash

# Affinity License uninstaller

if /bin/ls /Applications/Affinity\ * &> /dev/null ; then
    echo "One or more Affinity products still installed - leaving license file in place"
    exit 0
fi

[[ -d /Library/Application\ Support/Serif ]] && /bin/rm -rf /Library/Application\ Support/Serif
echo "No Affinity products remaining - Affinity license file removed"
