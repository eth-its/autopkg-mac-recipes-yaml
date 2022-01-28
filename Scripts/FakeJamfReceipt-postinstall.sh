#!/bin/bash
## postinstall script - for creating a fake Jamf receipt when no package is actually installed

## write the version to a defaults file
echo "Writing version as a Jamf Receipt"
/usr/bin/touch "/Library/Application Support/JAMF/Receipts/%RECEIPT_NAME%-%version%.pkg"
