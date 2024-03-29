#!/bin/bash
# based on Ruby postinstall script by Riley Shott:
# https://groups.google.com/group/munki-dev/browse_thread/thread/a2813e7f62535f13/63d127534541f863
# modifications:
# - always extract the helper tool with each install instead of skipping if it exists
# - remove xattr com.apple.quarantine removal

HELPER_SRC_PATH=/Applications/Dropbox.app/Contents/Resources/DropboxHelperInstaller.tgz
HELPER_DST_DIR=/Library/DropboxHelperTools
HELPER_DST_PATH="$HELPER_DST_DIR/DropboxHelperInstaller"

if [[ -e "$HELPER_SRC_PATH" ]]; then
    [[ -d "$HELPER_DST_DIR" ]] || mkdir "$HELPER_DST_DIR"
    /usr/bin/tar -C "$HELPER_DST_DIR" -xz -f "$HELPER_SRC_PATH"
    /usr/sbin/chown root:wheel "$HELPER_DST_PATH" "$HELPER_DST_DIR"
    /bin/chmod 04511 "$HELPER_DST_PATH"
    echo "Extracted Dropbox Helper to $HELPER_DST_PATH"
else
    echo "Expected $HELPER_SRC_PATH, but it was not present in the Dropbox dmg."
    exit 1
fi
