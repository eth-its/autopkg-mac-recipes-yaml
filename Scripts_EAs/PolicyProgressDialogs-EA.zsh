#!/bin/zsh

# This script determines whether a LaunchDaemon for running Policy Progress Dialogs is present

# Location of swiftDialog progress script
progress_script_location="/Library/Management/ETHZ/PolicyProgressDialogs"

result=""

# write 
if [[ -f "$progress_script_location/swiftDialogLauncher.zsh" ]]; then
    result="Installed"
fi

echo "<result>$result</result>"


