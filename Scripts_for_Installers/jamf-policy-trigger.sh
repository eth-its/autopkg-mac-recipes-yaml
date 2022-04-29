#!/bin/bash

: << DOC
Run a jamf policy trigger specified in Parameter 4.
Normal use case is to uninstall something before installing a newer version.
DOC

jamf policy -event "$4" ||:
sleep 3