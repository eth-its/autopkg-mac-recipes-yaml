#!/bin/zsh
# shellcheck shell=bash

: <<DOC
Postinstall script taken from MestReNova.munki in andrewvalentine-recipes
MestReNova produces an error on launch if the following directory structure and permissions are not set
See https://raw.githubusercontent.com/autopkg/andrewvalentine-recipes/master/MestReNova/MestReNova_permissions_warning.png
DOC

if [[ ! -d "/Library/Application Support/Mestrelab Research S.L." ]]; then
    echo "Creating cache dir and setting permissions"
    /bin/mkdir -p "/Library/Application Support/Mestrelab Research S.L./MestReNova/cache"
    /usr/sbin/chown -R root:admin "/Library/Application Support/Mestrelab Research S.L."
    /bin/chmod -R 755 "/Library/Application Support/Mestrelab Research S.L."
    /bin/chmod -R 777 "/Library/Application Support/Mestrelab Research S.L./MestReNova/cache"
fi
    
# For whatever reason, MestReNova does not respect preferences if set in a Configuration Profile:
/usr/bin/defaults write com.mestrelab.MestReNova General.SoftwareUpdateCheck.Days 0
/usr/bin/defaults write com.mestrelab.MestReNova General.SoftwareUpdateCheck.Enabled 0
