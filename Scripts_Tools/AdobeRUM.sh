#!/bin/bash

# run Adobe Remote Update Manager if installed
# this should be scoped only to clients that have Adobe CC SDL apps installed
if [[ -f '/usr/local/bin/RemoteUpdateManager' ]]; then
    /usr/local/bin/RemoteUpdateManager --action=install
else
    echo 'ERROR: Adobe remote update manager not installed.' 1>&2
    exit 1
fi

# don't report failure if some apps fail to install
exit 0

