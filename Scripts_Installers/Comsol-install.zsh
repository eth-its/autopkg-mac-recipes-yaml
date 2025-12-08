#!/bin/zsh

COMSOL_DMG_URL="$4"
DIR=/Library/Management/ETHZ/Comsol

# attach main image
echo "Mounting COMSOL image"
APPPATH="/Volumes/COMSOL_setup_dmg"
mkdir -p "$APPPATH"
hdiutil attach "$COMSOL_DMG_URL" -nobrowse -mountpoint "$APPPATH"

# find the setup script
installer=$(find "$APPPATH" -maxdepth 1 -name "COMSOL*.app" | head -n 1)
if [[ -d "$installer" ]]; then
    echo "Installing $installer" 
    if "$installer/Contents/Resources/setup" -s "$DIR/setupconfig.ini"; then
        echo "Installation succeeded"
        rm -rf "$DIR"
    else
        echo "ERROR: installation failed"
    fi
    hdiutil eject $APPPATH
else
    echo "ERROR: Installer not found."
    hdiutil eject $APPPATH
    exit 1
fi