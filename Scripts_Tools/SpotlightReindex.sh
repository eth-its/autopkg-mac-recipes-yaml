#!/bin/sh

# Re-index Spotlight
# https://krypted.com/mac-security/reindex-spotlight-from-the-command-line/

mdutil -a -i off
mdutil -a -i on
mdutil -E /

