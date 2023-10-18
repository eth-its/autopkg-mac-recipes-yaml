#!/bin/bash

# This script is inspired by https://machinecompatible.wordpress.com/2022/02/12/adding-an-airprint-printer-the-easy-way/
# to add a printer nearly identical to a GUI added printer. It requires end user click Continue button during set up process.
# Version 1.1
# Created 04-09-2022 by Michael Permann
# Modified 04-15-2022
# Modified 2023-10-18 by Graham Pugh

# Provide the printer DNS address as parameter 4 variable
PRINTER_DNS_ADDRESS="$4"
# Provide any optional printer defaults that need set as parameter 5 variable - get these with lpoptions -p $PRINTER_QUEUE_NAME -l
PRINTER_DEFAULT_OPTIONS="$5"


# Timeout timer
TIMER=0

CURRENT_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
USER_ID=$(/usr/bin/id -u "$CURRENT_USER")
PRINTER_ICON="/System/Library/CoreServices/AddPrinter.app/Contents/Resources/Printer.icns"
JAMF_HELPER="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
DESCRIPTION="Adding $PRINTER_DNS_ADDRESS failed due to communication error. Please make sure you are on the correct wireless network and try again. 

If it fails a second time, please contact the IT Dept for assistance."
WAIT="Please wait a few moments while we remove the existing printer.

This dialogue window will close itself when we are ready to proceed."
BUTTON1="OK"

# Queue name is the bonjour name with dashes replaced by underscores.
PRINTER_PPD_NAME=$(basename "$PRINTER_DNS_ADDRESS" | sed 's|-|_|g')

if [ -f "/private/etc/cups/ppd/${PRINTER_QUEUE_NAME}.ppd" ] 
then
    echo "Printer already exists delete it first to avoid duplicate"
    /usr/sbin/lpadmin -x "${PRINTER_QUEUE_NAME}"
    # /usr/sbin/lpadmin -x "${PRINTER_QUEUE_NAME}___Fax"
    /bin/launchctl asuser "$USER_ID" /usr/bin/sudo -u "$CURRENT_USER" "$JAMF_HELPER" -windowType utility -title "Removing Existing Printer" -description "$WAIT" -icon "$PRINTER_ICON" -button1 "$BUTTON1" -defaultButton "1" &
    sleep 10
    pkill jamfHelper
else
   echo "Printer does NOT already exist so nothing to delete"
fi

# Open the AddPrinter.app and pass the URL to the printer to add the device
# The end user must click the Continue button to complete the adding of the printer
open -a /System/Library/CoreServices/AddPrinter.app "$PRINTER_DNS_ADDRESS"

while [[ ! -f "/private/etc/cups/ppd/${PRINTER_PPD_NAME}.ppd" && TIMER -lt 20 ]] # wait for ppd file to be written to disk
do
   /bin/sleep 5
   TIMER=$((TIMER + 5))
   echo $TIMER
done

if [[ -f "/private/etc/cups/ppd/${PRINTER_PPD_NAME}.ppd" ]]
then
   if [ -n "$PRINTER_DEFAULT_OPTIONS" ] # Check if any default options are passed, if there are set them
   then
      /usr/sbin/lpadmin -p "$PRINTER_PPD_NAME" "$PRINTER_DEFAULT_OPTIONS"
      echo "Printer ${PRINTER_DNS_ADDRESS} added using queue name ${PRINTER_PPD_NAME} and default options of ${PRINTER_DEFAULT_OPTIONS} set"
   else
      echo "Printer ${PRINTER_DNS_ADDRESS} added using queue name ${PRINTER_PPD_NAME}"
   fi
else
   echo "Printer PPD file not created for some reason"
   pgrep AddPrinter && pkill AddPrinter
   /bin/launchctl asuser "$USER_ID" /usr/bin/sudo -u "$CURRENT_USER" "$JAMF_HELPER" -windowType utility -windowPosition lr -title "Add Printer Failed" -description "$DESCRIPTION" -icon "$PRINTER_ICON" -button1 "$BUTTON1" -defaultButton "1"
   exit 1
fi