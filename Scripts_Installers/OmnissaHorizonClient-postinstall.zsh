#!/bin/zsh
# shellcheck shell=bash

echo "Omnissa Horizon ID Package Postinstall: Enabling USB ..."

/Applications/Omnissa\ Horizon\ Client.app/Contents/Library/InitUsbServices.tool

echo "Omnissa Horizon ID Package Postinstall: Enabling USB ... done."

exit 0