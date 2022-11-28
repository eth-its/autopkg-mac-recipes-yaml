#!/bin/bash

# install a fresh copy of each of the printer drivers
jamf policy -event "ETH Printer Drivers HP-install" -forceNoRecon
jamf policy -event "ETH Printer Drivers Ricoh Vol3-install" -forceNoRecon
jamf policy -event "ETH Printer Drivers Ricoh Vol4-install" -forceNoRecon

# delete the old version of the app if it is installed
if [[ -d "/Applications/Utilities/ETH Printers.app" ]]; then
    rm -Rf "/Applications/Utilities/ETH Printers.app"
fi

# also delete any version of the app that was placed in a subfolder
if [[ -d "/Applications/Utilities/ETH Printers.localized" ]]; then
    rm -Rf "/Applications/Utilities/ETH Printers.localized"
fi

# forget package
pkgutil --pkgs=ch.ethz.ethprinters.pkg && pkgutil --forget ch.ethz.ethprinters.pkg

# wait a few seconds to try and prevent the app getting installed in a subfolder
sleep 5
