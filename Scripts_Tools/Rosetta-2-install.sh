#!/bin/bash

: << DOC
Determine whether Rosetta is installed - install if not. 
Original source: https://github.com/grahampugh/Rosetta-2-install/blob/main/Rosetta-2-install.sh
DOC

max_wait_count=10

wait_for_network() {
    # check for 
    n=1
    while [[ $(ifconfig -a inet 2>/dev/null | sed -n -e '/127.0.0.1/d' -e '/0.0.0.0/d' -e '/inet/p' | wc -l) -lt 1 ]] ; do
        if [[ $n -gt $max_wait_count ]] ; then
            echo "[Rosetta-2-install] No network - Rosetta 2 installation failed"
            exit 1
        fi
        echo "[Rosetta-2-install] Waiting for network access... attempt $n"
        sleep 5
        (( n++ ))
    done
    while ! curl --silent http://captive.apple.com/hotspot-detect.html 2>/dev/null | grep -q Success; do
        echo "[Rosetta-2-install] Waiting for network access"
        sleep 5
    done
}

# is this an ARM Mac?
if [[ "$(/usr/bin/arch)" == "arm64"* ]]; then
    echo "[Rosetta-2-install] This is an arm64 Mac."
    # is Rosetta 2 installed?
    if /usr/bin/pgrep oahd >/dev/null 2>&1 ; then
        echo "[Rosetta-2-install] Rosetta 2 is already installed"
    else
        echo "[Rosetta-2-install] Rosetta 2 is missing - installing"
        wait_for_network
        echo "[Rosetta-2-install] Network is connected: proceeding with Rosetta 2 installation..."
        echo
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        echo 
        if /usr/bin/pgrep oahd >/dev/null 2>&1 ; then
            echo "[Rosetta-2-install] Rosetta 2 is now installed"
        else
            echo "[Rosetta-2-install] Rosetta 2 installation failed"
            exit 1
        fi
    fi
else
    echo "[Rosetta-2-install] This is an Intel Mac."
fi

exit 0