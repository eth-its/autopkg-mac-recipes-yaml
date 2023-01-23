#!/bin/zsh
# shellcheck shell=bash

# Check for whether automatic Software Updates is enabled for all update types

prefs="/Library/Preferences/com.apple.SoftwareUpdate.plist"
result="Compliant"

# AutomaticCheckEnabled = 1;
AutomaticCheckEnabled=$(/usr/libexec/PlistBuddy -c "Print :AutomaticCheckEnabled" "$prefs" 2>/dev/null)
if [[ "$AutomaticCheckEnabled" != "true" ]]; then
    result="Not Compliant"
fi

# AutomaticDownload = 1;
AutomaticDownload=$(/usr/libexec/PlistBuddy -c "Print :AutomaticDownload" "$prefs" 2>/dev/null)
if [[ "$AutomaticDownload" != "true" ]]; then
    result="Not Compliant"
fi

# AutomaticallyInstallMacOSUpdates = 1;
AutomaticallyInstallMacOSUpdates=$(/usr/libexec/PlistBuddy -c "Print :AutomaticallyInstallMacOSUpdates" "$prefs" 2>/dev/null)
if [[ "$AutomaticallyInstallMacOSUpdates" != "true" ]]; then
    result="Not Compliant"
fi

# ConfigDataInstall = 1;
ConfigDataInstall=$(/usr/libexec/PlistBuddy -c "Print :ConfigDataInstall" "$prefs" 2>/dev/null)
if [[ "$ConfigDataInstall" != "true" ]]; then
    result="Not Compliant"
fi

# CriticalUpdateInstall = 1;
CriticalUpdateInstall=$(/usr/libexec/PlistBuddy -c "Print :CriticalUpdateInstall" "$prefs" 2>/dev/null)
if [[ "$CriticalUpdateInstall" != "true" ]]; then
    result="Not Compliant"
fi

echo "<result>$result</result>"
exit 0