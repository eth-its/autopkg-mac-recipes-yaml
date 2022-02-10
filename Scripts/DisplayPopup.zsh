#!/bin/zsh
# shellcheck shell=bash

: <<DOC 
A script to use in Jamf Pro to pop up a simple display dialog. 
Parameter 4 is the display message
Parameter 5 is the button text
DOC

if [[ -z "${4}" ]]; then
    display_message="Your administrator has not configured this message. Please contact them."
else
    display_message="${4}"
fi

if [[ -z "${5}" ]]; then
    button_text="OK"
else
    button_text="${5}"
fi

/usr/bin/osascript -e "tell application \"Self Service\" to display dialog \"${display_message}.\" buttons {\"${button_text}\"} with icon caution giving up after 120"