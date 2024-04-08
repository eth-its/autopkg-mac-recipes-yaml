#!/bin/bash
OperaVersion=""
if [ -f "/Applications/Opera.app/Contents/Info.plist" ]; then
    OperaVersion=$(/usr/bin/defaults read "/Applications/Opera.app/Contents/Info.plist" CFBundleShortVersionString)
fi

echo "<result>$OperaVersion</result>"

exit 0