#!/bin/zsh
# shellcheck shell=bash

: <<DOC 
erase-install run script for downloading the latest available Install macOS Monterey.app
by Graham Pugh
DOC

jamf policy -event "erase-install-install"

/Library/Management/erase-install/erase-install.sh --os 12 --update --check-power

