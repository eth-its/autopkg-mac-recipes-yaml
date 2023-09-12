#!/bin/zsh
# shellcheck shell=bash
# shellcheck disable=SC2034,SC2296
# these are due to the dynamic variable assignments used in zsh and not recognised by shallcheck

# install Rosetta 2
jamf policy -event Rosetta-2-install

# if Parameter 4 is set to "dialog", we will install swiftDialog and display a message
if [[ "$4" == "dialog" ]]; then
    jamf policy -event swiftDialog-install
fi

# Wait for user to be logged in
dockStatus=$(pgrep -x Dock)
echo "Waiting for Desktop"
while [[ "$dockStatus" == "" ]]; do
  echo "Desktop is not loaded. Waiting."
  sleep 2
  dockStatus=$(pgrep -x Dock)
done


# start a welcome window if Parameter 4 is set to "dialog"
if [[ "$4" == "dialog" ]]; then
    /usr/local/bin/dialog \
        --title "Welcome to your new ETH Mac" \
        --message "Your computer is being prepared for first use at ETH Zürich.\n\nThe **ETH Self Service** app will also be installed, which is your portal to a range of additional applications and tools that we have prepared for you to install seamlessly with a single click.\n\nIf your IT administrator assigned any applications to be installed automatically on this computer, these installations will happen in the background, and you will see notifications as they get installed.\n\nSome configurations that are necessary to allow the Mac to function on the ETH network may also be applied. For more information, contact your IT administrator.\n\n" \
        --button1text "Click to dismiss this message" \
        --icon "/System/Library/CoreServices/Setup Assistant.app" \
        --messagefont "size=16" \
        --ontop &
fi

# run any other triggers that are added to the script parameters 5-11 (up to 7)
for i in {5..11}; do
    eval_string="${(P)i}"
    if [[ "$eval_string" ]]; then
        echo "Running policy trigger '${eval_string}'"
        jamf policy -event "${eval_string}"
    fi
done
