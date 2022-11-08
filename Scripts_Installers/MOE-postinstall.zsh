#!/bin/zsh
# shellcheck shell=bash

: <<DOC
Configures the MOE license.dat file

Required parameters:
4 - Major Version e.g. 2019.0102
4 - Server string e.g. 123.145.167.89 001122334455 6677
DOC

folder_name=$(find /Applications -name "moe*$MAJOR_VERSION" -type d -maxdepth 1 | head -n 1)

echo "SERVER $5
USE_SERVER" > "$folder_name/license.dat"
