#!/bin/bash

APP="/Applications/Microsoft Word.app"
if [[ ! -e "$APP" ]]; then
    echo "$APP is not installed."
    oldest_version_full="None"
else 
    myWord_full=$(defaults read "/Applications/Microsoft Word.app/Contents/Info.plist" CFBundleVersion )
    myExcel_full=$(defaults read "/Applications/Microsoft Excel.app/Contents/Info.plist" CFBundleVersion )
    myPowerPoint_full=$(defaults read "/Applications/Microsoft PowerPoint.app/Contents/Info.plist" CFBundleVersion )
    myOutlook_full=$(defaults read "/Applications/Microsoft Outlook.app/Contents/Info.plist" CFBundleVersion )
    myOneNote_full=$(defaults read "/Applications/Microsoft OneNote.app/Contents/Info.plist" CFBundleVersion )
    oldest_version_full=$(echo "$myWord_full" "$myExcel_full" "$myPowerPoint_full" "$myOutlook_full" "$myOneNote_full" | tr ' ' '\n' | sort | head -n 1 )
fi
echo "<result>$oldest_version_full</result>"

exit 0