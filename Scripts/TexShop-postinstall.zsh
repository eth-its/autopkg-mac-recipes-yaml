#!/bin/zsh

autoload is-at-least

:<<DOC
MacTeX installs TexShop.app into the /Applications/TeX folder,
so we use an AutoPkg recipe that repackages TexShop.app so that
it is installed in that directory.

But if somebody has an existing installation in /Applications,
we end up with two versions.

So, This postinstall script checks if there is an existing version
which is older or the same as the version in the /Applications/TeX
folder, and deletes it.
DOC

get_version() {
    plist="$1/Contents/Info.plist"
    version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist")
    return $version
}

tex_location='/Applications/TeX/TexShop.app'
standalone_location='/Applications/TexShop.app'

# Check that the installation worked
if [[ -d "$tex_location" ]]; then
    tex_version=$(get_version "$tex_location")
    echo "TexShop.app installation found at $tex_location. Version: $tex_version"
else
    echo "TexShop.app installation not found at $tex_location. Version: $tex_version"
    tex_version=0
fi

# Check that an installation in Applications is also present
if [[ -d "$standalone_location" ]]; then
    standalone_version=$(get_version "$standalone_location")
    echo "TexShop.app installation found at $standalone_location. Version: $standalone_version"
else
    echo "TexShop.app installation not found at $standalone_location. Version: $standalone_version"
    standalone_version=0
fi

# Compare versions. Delete existing if version is older or equal to TeX installation
if [[ $standalone_version == 0 ]]; then
    echo "No standalone version. Nothing to do."
elif is-at-least "$standalone_version" "$tex_version"; then
    echo "TeX version ($tex_version) is newer or equal. Deleting standalone version ($standalone_version)."
    if /bin/rm -rf "$standalone_location"; then
        echo "Deleted $standalone_location"
    else
        echo "WARNING: failed to delete $standalone_location"
    fi
else
    echo "Standalone ($standalone_version) is newer than the TeX version ($tex_version). Leaving it there."
fi

