#!/bin/sh
echo Uninstalling Dante Controller

# Note: The uninstall script is only available when opening the pkg file.
# As a result, it's highly likely a customer won't keep the uninstall script 
# from the version they installed and will be trying to uninstall using the script
# from a newer DC package.  We therefore try to remove all legacy files / packages
# in addition to the current install paths.

pkill "Dante Controller"

err=0
trap 'err=1' ERR

# - Batch pkgutil operations to reduce process spawns
# - Parallelize directory removal operations
# - Cache pkgutil package list for faster lookups

# Cache list of installed packages once for performance
INSTALLED_PKGS=$(pkgutil --pkgs 2>/dev/null)

# Function to remove and forget a package, checking cached list first
forget_package() {
    pkg="$1"
    # Use cached package list instead of spawning pkgutil for each check
    if echo "$INSTALLED_PKGS" | grep -q "^${pkg}$"; then
        pkgutil --forget "$pkg" > /dev/null 2>&1
    fi
}

# Function to remove a directory if it exists
remove_directory() {
    directory="$1"
    if [ -d "$directory" ]; then
        rm -rf "$directory"
    fi
}

# Function to remove multiple directories in parallel (background jobs)
remove_directories_parallel() {
    for dir in "$@"; do
        if [ -d "$dir" ]; then
            rm -rf "$dir" &
        fi
    done
    wait  # Wait for all background deletions to complete
}

#------------------------------------------------------------------------------
# Remove app directories in parallel for faster deletion
#------------------------------------------------------------------------------

remove_directories_parallel \
    "/Applications/Dante Controller.app" \
    "/Applications/Dante Updater.app" \
    "/Library/Application Support/Audinate/DanteUpdater" \
    "/Applications/Dante Activator.app" \
    "/Library/Application Support/Audinate/DanteActivator.app"

#------------------------------------------------------------------------------
# Batch forget package operations (single batch reduces overhead on Tahoe)
#------------------------------------------------------------------------------

forget_package "com.audinate.dante.pkg.DanteController"
forget_package "com.audinate.dante.pkg.DanteUpdater"
forget_package "com.audinate.dante.pkg.DanteActivator"
forget_package "com.audinate.dante.pkg.DanteActivatorLegacy"

#------------------------------------------------------------------------------
# Deregister with ConMon
#------------------------------------------------------------------------------

# If ConMon is still installed for some reason (e.g. OEM Apps) - make sure we deregister
# Dante Controller's interest in it
conmon_use_script_path="/Library/Application Support/Audinate/ConMon.bundle/Contents/Resources/"
if [ -d "$conmon_use_script_path" ]; then
    "$conmon_use_script_path"/use.sh -r com.audinate.dante.controller
fi

#------------------------------------------------------------------------------
# Remove and forget the "package" version files
#------------------------------------------------------------------------------

remove_directory "/Library/Application Support/Audinate/DanteController"

forget_package "com.audinate.dante.pkg.DanteControllerPackage"

#------------------------------------------------------------------------------
# Uninstall Dante Update Helper
#------------------------------------------------------------------------------

if [ -x "/Library/Application Support/Audinate/DanteUpdateHelper/uninstall.sh" ]; then
    "/Library/Application Support/Audinate/DanteUpdateHelper/uninstall.sh" > /dev/null 2>&1
fi

echo Done
exit $err
