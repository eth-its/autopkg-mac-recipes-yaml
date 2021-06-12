#!/bin/sh

# https://themacbeginner.com/disable-drop-shadow-mac-os-screenshots/

/usr/bin/defaults write com.apple.screencapture disable-shadow -bool TRUE
killall SystemUIServer

