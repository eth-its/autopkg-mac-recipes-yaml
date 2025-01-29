#!/bin/zsh
# shellcheck shell=bash

# Postinstall for IBM Storage Protect

# move any certificates back in place
tempdir=/var/folders/tivoli-reinstall
certdir="/Library/Application Support/tivoli/tsm/client/ba/bin"
if [[ $tempdir ]]; then 
    cp "$tempdir/dsmcert.kdb" "$tempdir/dsmcert.sth" "$tempdir/dsmcert.idx" "$certdir"
    rm -rf $tempdir
fi
