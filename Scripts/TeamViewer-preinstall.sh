#!/bin/sh
## preinstall script

# Set TeamViewer to only restart the service on installation
# This is achieved by creating the following file
# before installing the package. the file should contain the
# path to which TeamViewer should be installed, as this is
# used elsewhere in the TeamViewer pkg postinstall script.
# (thanks to @cdietrich)

echo "/Applications" > /tmp/tvPath
