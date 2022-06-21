#!/bin/zsh
# shellcheck shell=bash

## Script to remove old versions before installing Enpass, as the App Store version installs into a separate folder if there is already a package-installed version present, and vice versa.

# Check whether the new version was installed manually and has been put in the wrong place
find /Applications -type d -name "Enpass*" -maxdepth 1 -exec rm -rf {} +
