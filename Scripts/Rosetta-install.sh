#!/bin/bash

: << DOC
Determine whether Rosetta is installed - install if not. 
DOC

# is this an ARM Mac?
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    echo "This is an arm64 Mac."
    # is rosetta 2 installed?
    if [[ -f "/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist" ]]; then
        echo "Rosetta 2 is already installed"
    else
        echo "Rosetta 2 is missing - installing"
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        if [[ -f "/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist" ]]; then
            echo "Rosetta 2 is now installed"
        else
            echo "Rosetta 2 installation failed"
            exit 1
        fi
    fi
else
    echo "This is an Intel Mac."
fi

exit 0