#!/bin/bash

# The Sophos Anti-Virus Enterprise Console Client (EC) installer policy 
# includes a pre-install script which places the grouppath.txt file
# in a specific location: /Library/Management/SophosEndpointInstaller
# This extension attribute looks for the presence of this file.
# This is done to differentiate between the EC and standard versions
# of Sophos.

# Get SophosEC Group Path
install_dir="/Library/Management/SophosEndpointInstaller" 
sophos_url=$(cat "${install_dir}/grouppath.txt")

[[ ! "$sophos_url" ]] && sophos_url="Unmanaged"

echo "<result>${sophos_url//\\\\/\\}</result>"

exit 0