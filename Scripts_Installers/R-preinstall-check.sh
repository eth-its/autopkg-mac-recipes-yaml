#!/bin/bash
## preinstall script

# Application installation requires the installation or R. This script checks if R is already installed 

if [ -d "/Applications/R.app" ]; then
    echo "R is already installed. Skipping"
else
    echo "R is not installed. Need to install R."
    arch=$(uname -m)
    /usr/local/bin/jamf policy -event "R ${arch}-install"
fi
