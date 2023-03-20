#!/bin/bash

# run Adobe Remote Update Manager if installed; install if not present
# this should be scoped only to clients that have Adobe CC apps installed

# install if not present
if [[ ! -f '/usr/local/bin/RemoteUpdateManager' ]]; then
    jamf policy -event AdobeRUM-install
fi

# now run
if [[ -f '/usr/local/bin/RemoteUpdateManager' ]]; then
    /usr/local/bin/RemoteUpdateManager --action=install
else
    echo 'ERROR: Adobe Remote Update Manager not installed.' 1>&2
    exit 1
fi

