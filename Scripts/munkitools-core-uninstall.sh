#!/bin/bash

#######################################################################
#
# munkitools-core-uninstall.sh Script for Jamf Pro
#
#######################################################################

munkidir="/usr/local/munki"

# remove all munki core files

if [[ -d "$munkidir" ]]; then
    rm -Rf "$munkidir" ||:
fi

# check that they did remove
if [[ -d "$munkidir" ]]; then
    echo "Munki directory failed to be removed"
    exit 1
fi

# forget package
pkg_id="com.googlecode.munki.core"
if pkgutil --pkgs="$pkg_id"; then
    pkgutil --forget "$pkg_id"
fi
