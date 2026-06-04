#!/bin/zsh
# shellcheck shell=bash

# LMStudio version detection extension attribute
# Requires the adapted package provided by com.github.eth-its-recipes.pkg.LMStudio

echo '<result>'$(echo $(defaults read /Applications/LM\ Studio.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null||echo None)|tr '+' '.')'</result>'
exit 0
        