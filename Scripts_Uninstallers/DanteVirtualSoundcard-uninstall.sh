#!/bin/sh

echo "Stopping Dante Virtual Soundcard"

# Force quit DVS if it's running
killall "Dante Virtual Soundcard"

# Hard stop new Dante Services

launchctl unload -w /Library/LaunchDaemons/com.audinate.dante.DanteVirtualSoundcard.plist > /dev/null 2>&1
rm -f /Library/LaunchDaemons/com.audinate.dante.DanteVirtualSoundcard.plist
launchctl remove com.audinate.dante.DanteVirtualSoundcard > /dev/null 2>&1
#launchctl remove com.audinate.dante.ConMon > /dev/null 2>&1

# Hard stop old Dante services

rc=/Library/Audinate/DanteVirtualSoundcard/DanteVirtualSoundcard/DanteVirtualSoundcard

if [ -x $rc ]
then
    # echo Stopping Dante Virtual Soundcard ..
    $rc stop >/dev/null 2>&1
else
    # echo "DVS rc script not found"
    :
fi


# Remove DVS Audio PlugIn
rm -rf /Library/Audio/Plug-Ins/HAL/DvsAudioPlugIn.driver
pkill -2 -f coreaudiod

echo Removing Dante Virtual Soundcard ..

# Clear license metadata
/Library/Application\ Support/Audinate/DanteVirtualSoundcard/Tools/dvs_licenser --clear

# New stuff

rm -rf /Library/Application\ Support/Audinate/DanteVirtualSoundcard
#rm -rf /Library/Application\ Support/Audinate/ConMon
rm -rf /Applications/DanteVirtualSoundcard*
rm -rf /Applications/Dante\ Virtual\ Soundcard*
#rm -rf /Applications/Dante\ Controller.app

# Prefs

# Remove the manager preferences in all containers of the Mac OS defaults system
# This ensures the preferences are not carried over to a new installation.
defaults delete-all /Library/Preferences/com.audinate.dante.dvs

#rm -f /Library/Preferences/com.audinate.dante.*
rm -f ~/Library/Preferences/com.audinate.DanteVirtualSoundcard.plist
rm -f /Library/Preferences/com.audinate.dante.dvs.plist
rm -f /Library/Preferences/com.audinate.dante.dvs.lic
rm -f /Library/Preferences/com.audinate.dante.apec.conf
rm -f /Library/Preferences/com.audinate.dante.ptp.conf
rm -f /Library/Preferences/com.audinate.dante.dvs.ddm.conf
rm -f /Library/Preferences/com.audinate.dante.dvs.device_data
#rm -rf /Library/Preferences/com.audinate.dante.install

# Receipts

#rm -rf /Library/Receipts/boms/com.auindate.*.bom
rm -rf /Library/Receipts/DVS?User?Interface.pkg
#rm -rf /Library/Receipts/Dante?Controller.pkg
rm -rf /Library/Receipts/Dante?Virtual?Soundcard.pkg 2>/dev/null
#rm -rf /Library/Receipts/ConMon.pkg
pkgutil -f --forget com.audinate.dante.dvs.pkg 2>/dev/null \ 
    --forget com.audinate.dante.dvs.ui.pkg \
    > /dev/null 2>&1

# Old stuff
rm -f /Library/Logs/Audinate/*_ptp.txt
rm -f /Library/Logs/Audinate/*_apec.txt
#rm -rf /Library/Audinate
#rm -rf /Library/Logs/Audinate
rm -f   /Library/PreferencePanes/DanteVirtualSoundcard.prefPane 2>/dev/null
rm -f   /Library/Preferences/com.audinate.dante.virtualsoundcard.plist
#rm -f  /Library/Receipts/dantecontroller.pkg
rm -f   /Library/Receipts/DanteForMac-Audinate.pkg  2>/dev/null
rm -f   /Library/Receipts/dantevirtualsoundcard*.pkg  2>/dev/null
rm -rf  /Library/StartupItems/DanteVirtualSoundcard

# Any remaining receipts

#rm -rf /Library/Receipts/boms/com.audinate.dante.*
#rm -rf /Library/Receipts/conmon*.pkg
#rm -rf /Library/Receipts/comaudinatedante*.pkg
rm -rf /Library/Receipts/dvsui.pkg
pkgutil -f --forget com.audinate.dante.DanteVirtualSoundcard.pkg 2>/dev/null \ 
    --forget com.audinate.dante.DanteVirtualSoundcard.launchd.pkg \
    --forget com.audinate.dante.DanteVirtualSoundcard.ui.pkg \
    > /dev/null 2>&1
    
# If ConMon is still installed for some reason - make sure we deregister DVS's interest in it
#(This is in case the user uses the new DVS uninstaller, but the old DVS used the shared conmon).
conmon_use_script_path="/Library/Application Support/Audinate/ConMon.bundle/Contents/Resources/"
if [ -d "$conmon_use_script_path" ]; then
    "$conmon_use_script_path"/use.sh -r com.audinate.dante.dvs
fi

echo Done.

