#!/bin/zsh
# shellcheck shell=bash

# Check for Adobe RUM
rum="/usr/local/bin/RemoteUpdateManager"

if [[ -f "$rum" ]]; then
    echo "Adobe RUM installed - removing..."
    rm -f "$rum"
else
    echo "Adobe RUM not installed - nothing to do"
fi
