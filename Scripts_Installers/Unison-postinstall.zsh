#!/bin/zsh
# shellcheck shell=bash

## Script to install the Unison command line tool

cltool_path="/usr/local/bin/unison"

# delete older version first, in case it needs to be updated
if [[ -f "$cltool_path" ]]; then
    rm -f "$cltool_path"
fi

# now move the tool into place
if cp "/Applications/Unison.app/Contents/MacOS/cltool" "$cltool_path"; then
    echo "Unison cltool installed at $cltool_path"
else
    echo "Unison cltool could not be installed"
    exit 1
fi