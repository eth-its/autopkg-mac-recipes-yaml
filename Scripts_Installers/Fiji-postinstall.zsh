#!/bin/zsh
# shellcheck shell=bash

# Change permissions so that both root and members of the admin group
# have read and write permissions to the application. This is needed
# to allow the built-in update mechanism to work.

if [ -d "/Applications/Fiji.app" ]; then
    echo "Setting permissions and ownership on Fiji.app"
    chmod -R 775 "/Applications/Fiji.app"
    chown -R root:staff "/Applications/Fiji.app"
    chown -R root:staff "/Library/Application Support/Fiji"
fi
