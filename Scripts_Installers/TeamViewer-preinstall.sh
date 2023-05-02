#!/bin/sh
## preinstall script

# Set TeamViewer to only restart the service on installation
# This is achieved by creating the following files
# before installing the package. 

touch /tmp/tvonlystartservice
