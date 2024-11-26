#!/bin/zsh
# shellcheck shell=bash

# Support App Config version finder extension attribute

version="None"

# look for the new config script
if [[ -f "//Library/Management/ETHZ/SupportApp/status_update.zsh" ]]; then
    # now look for the version_info file in the GOLD folder
    echo "<result>new</result>"
    else "<result>old</result>"
fi


exit 0