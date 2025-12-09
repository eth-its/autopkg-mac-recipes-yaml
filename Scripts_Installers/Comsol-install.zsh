#!/bin/zsh

COMSOL_DMG_URL="$4"
DIR=/Library/Management/ETHZ/Comsol

# download image to /tmp, 
cd /tmp
curlexit=1
while [[ $curlexit -gt 0 ]] ; do
echo "$(date) : Starting Image Download"
curl -C - -O "$COMSOL_DMG_URL" 
curlexit=$?
if [[ $curlexit -gt 0 ]]; then echo "$(date) : Download interrupted, resuming.." ; fi
done

echo "$(date) : COMSOL image download successful"
IMAGENAME="$(basename "$COMSOL_DMG_URL")"

# attach main image
echo "$(date) : Mounting COMSOL image"
APPPATH="/Volumes/COMSOL_setup_dmg"
mkdir -p "$APPPATH"
hdiutil attach "$IMAGENAME" -nobrowse -mountpoint "$APPPATH"

# find the setup script
installer=$(find "$APPPATH" -maxdepth 1 -name "COMSOL*.app" | head -n 1)
if [[ -d "$installer" ]]; then
    echo "$(date) : Installing $installer" 
    caffeinate & echo $! >/tmp/coffeepid #prevent machine sleep,until the installer has run out
    if "$installer/Contents/Resources/setup" -s "$DIR/setupconfig.ini"; then
        echo "$(date) : Installation succeeded"
        rm -rf "$DIR"
    else
        echo "$(date) : ERROR: installation failed"
    fi
    hdiutil eject "$APPPATH"
    rm -f /tmp/"$IMAGENAME"
    pkill -F /tmp/coffeepid
    rm -f /tmp/coffeepid
    echo "$(date) : Image unmounted and deleted, exiting"
else
    echo "$(date) : ERROR: Installer not found."
    hdiutil eject "$APPPATH"
    exit 1
fi