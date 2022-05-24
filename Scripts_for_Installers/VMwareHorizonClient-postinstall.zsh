#!/bin/zsh
# shellcheck shell=bash

echo "VMware Horizon ID Package Postinstall: Enabling USB ..."

/Applications/VMware\ Horizon\ Client.app/Contents/Library/InitUsbServices.tool

echo "VMware Horizon ID Package Postinstall: Enabling USB ... done."

exit 0
