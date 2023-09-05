#!/bin/zsh
# shellcheck shell=bash
# shellcheck disable=SC2034,SC2296
# these are due to the dynamic variable assignments used in zsh and not recognised by shallcheck

# Install swiftDialog
jamf policy -event swiftDialog-install

# Wait for user to be logged in

dockStatus=$(pgrep -x Dock)
echo "Waiting for Desktop"
while [[ "$dockStatus" == "" ]]; do
  echo "Desktop is not loaded. Waiting."
  sleep 2
  dockStatus=$(pgrep -x Dock)
done

# start a welcome window
/usr/local/bin/dialog \
	--title "Welcome to your new ETH Mac" \
    --message "Your computer is being prepared for first use at ETH Zürich.\n\nThe **ETH Self Service** app will also be installed, which is your portal to a range of additional applications and tools that we have prepared for you to install seamlessly with a single click.\n\nIf your IT administrator assigned any applications to be installed automatically on this computer, these installations will happen in the background, and you will see notifications as they get installed.\n\nSome configurations that are necessary to allow the Mac to function on the ETH network may also be applied. For more information, contact your IT administrator.\n\n" \
    --button1text "Click to dismiss this message" \
    --icon "/System/Library/CoreServices/Setup Assistant.app" \
    --messagefont "size=16" \
    --ontop &

# install any other apps that are added to the script parameters (up to 7)
for i in {4..10}; do
    eval_string="${(P)i}"
    if [[ "$eval_string" ]]; then
        echo "Running policy trigger '${eval_string}-install'"
        jamf policy -event "${eval_string}-install"
    fi
done
