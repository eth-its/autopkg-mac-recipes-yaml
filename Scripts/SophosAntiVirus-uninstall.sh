#!/bin/bash
## script to uninstall Sophos Anti-Virus

# Uninstall existing copy of Sophos 8.x by checking for the
# Sophos Antivirus uninstaller package in /Library/Sophos Anti-Virus.
# If present, the uninstallation process is run.
if [ -d "/Library/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" ]; then
    echo "Sophos AV v.8 present on Mac. Uninstalling."
    /usr/sbin/installer -pkg "/Library/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" -target "/"
    killall SophosUIServer
elif [ -d "/Library/Application Support/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" ]; then
    echo "Sophos AV v.8 present on Mac. Uninstalling."
    /usr/sbin/installer -pkg "/Library/Application Support/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" -target "/"
    killall SophosUIServer
else
    echo "Sophos Anti-Virus 8.x Uninstaller Not Present"
fi

# Uninstall existing copy of Sophos 9.x by checking for the InstallationDeployer 
# application in the following locations:
#
# Sophos AV Cloud (saas), Sophos AV Home Edition (he),
# Sophos AV Standalone (opm-sa), Sophos AV Enterprise (opm)
# /Library/Application Support/Sophos/{edition}/Installer.app/Contents/MacOS/
# /Library/Application Support/Sophos/{edition}/Installer.app/Contents/MacOS/tools/
#
# If the InstallationDeployer application is present in the 
# Contents/MacOS/tools directory, the uninstallation process is run using the 
# InstallationDeployer tool located there.
#
# If the InstallationDeployer application is present only in the 
# Contents/MacOS directory, the uninstallation process is run using the 
# InstallationDeployer tool located there.
#
# The reason for the directory-specific check is that running the 
# InstallationDeployer application from Contents/MacOS on Sophos 9.1.x 
# and later will cause the Sophos uninstaller application to launch in the 
# dock and interfere with a normal installation via installer package.
#
# For more information, see the link below:
# http://www.sophos.com/en-us/support/knowledgebase/14179.aspx

# additional information for tamper protected installations
if [[ "$4" && "$4" != "None" ]]; then
    tamper_parameter="--tamper_password $4" 
else
    tamper_parameter=""
fi

AppSupport="/Library/Application Support/Sophos"
for edition in he opm-sa opm saas; do
    InstallerBase="${AppSupport}/${edition}/Installer.app/Contents/MacOS"
    for tool in "${InstallerBase}/tools/InstallationDeployer" "${InstallerBase}/InstallationDeployer"; do
        if [ -f "${tool}" ]; then
            chmod +x "${tool}"
            echo "Running Sophos Uninstaller: ${tool}"
            # shellcheck disable=SC2086
            "${tool}" --remove ${tamper_parameter}
        fi
    done
done

# forget packages
pkgutil --pkgs=%PKG_ID% && pkgutil --forget %PKG_ID%

# remove the Sophos OU file if present
install_dir="/Library/Management/SophosEndpointInstaller"
group_path="${install_dir}/grouppath.txt"
if [[ -f "${group_path}" ]]; then
    echo "Removing grouppath.txt"
    rm -f "${group_path}"
fi
if [[ -f "${install_dir}" ]]; then
    echo "Removing ${install_dir}"
    rm -Rf "${install_dir}"
else
    echo "${install_dir} not present"
fi


