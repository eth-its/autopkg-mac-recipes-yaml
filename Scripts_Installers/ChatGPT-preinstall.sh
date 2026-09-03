#!/bin/zsh

if [[ $(defaults read /Applications/ChatGPT.app/Contents/Info.plist CFBundleIdentifier) == "com.openai.chat" ]] ; then
    pkill -9 ChatGPT
    rm -rf "/Applications/ChatGPT.app"
fi
T