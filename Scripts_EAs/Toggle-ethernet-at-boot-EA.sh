#!/bin/zsh
# check if toggle ethernet at boot is installed
version="None"
# look for the Scripts folder
if [[ -d "/Library/Management/ETHZ/Scripts/" ]]; then
    if [[ -f /Library/Management/ETHZ/Scripts/toggle-ethernet.sh ]] ; then version='1.0' ; fi
fi
echo "<result>$version</result>"

exit 0