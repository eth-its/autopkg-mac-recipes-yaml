#!/bin/bash

# ------------------------------------------------------------
# Printer Installation Template
# Graham Pugh 2015-10-05
# Adapted for JSS 2017-01-19
# ETH minor edits 2018-04-26
# Change jamf policy trigger 2020-03-09
# Change policy triggers for printer drivers 2021-12-13
# Adapted for IPP printing 2022-02-09
# ------------------------------------------------------------

# Variables. Edit these. The script will remove any existing installation of a printer
# with the same name as defined by 'printername'
address="$4"
printername="$5"
gui_display_name="$6"
location="$7"

# leave this empty if you wish to use the generic PS PPD print driver
# or choose an existing .ppd.gz file from /Library/Printers/PPDs/Contents/Resources/
# Note the best way to populate this folder is using Apple-supplied drivers (HP or Xerox)
# or with an installer pkg from your printer vendor.
driver_file="$8"

# set this to 1 if you wish to use the generic PS print driver
# or 0 if you have specified a driver_file above
generic_ppd=0

# set this to 1 if you wish this printer to be default (note the last-run script will take precedence).
default_printer="${10}"

# Populate these options if you want to set specific options for the printer. E.g. duplexing installed, etc.
options_global="-o PageSize=A4 -o auth-info-required=username,password -o Duplex=DuplexNoTumble -o printer-is-shared=false -o printer-error-policy=abort-job"

# Further options that can be supplied via Jamf Parameter. These must include the "-o" flag for each option
options_specific="$9"

# default printer driver for ETH PullPrint queue ("card-ethz")
default_driver_file="HP Color MFP E87640-50-60.gz"

### Stop editing. Don't change anything below here.
### -------------------------------------------------------------------------------------

# fill in blank variables
if [[ -z "$location" ]]; then
    location=$printername
fi
if [[ -z "$gui_display_name" ]]; then
    gui_display_name=$printername
fi
if [[ -z "$gui_display_name" ]]; then
    gui_display_name=$printername
fi

if [ $generic_ppd = 1 ]; then
driver_ppd="/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Versions/A/Resources/Generic.ppd"
else
    if [[ -z "$driver_file" ]]; then
        driver_file=$default_driver_file
    fi
	driver_ppd_dest="/Library/Printers/PPDs/Contents/Resources"
	driver_ppd="${driver_ppd_dest}/${driver_file}"

    if [[ ! -f "$driver_ppd" ]]; then
        # driver not present. Try installing ETH printer drivers using Jamf policy triggers
        echo "Installing drivers..."
        /usr/local/bin/jamf policy -event "ETH Printer Drivers HP-install" -forceNoRecon
        /usr/local/bin/jamf policy -event "ETH Printer Drivers Ricoh Vol3-install" -forceNoRecon
        /usr/local/bin/jamf policy -event "ETH Printer Drivers Ricoh Vol4-install" -forceNoRecon

        # Look again, exit 1 if still not present
        if [[ ! -f "$driver_ppd" ]]; then
            echo "Could not obtain PPD. Bailing."
            exit 1
        fi
    fi
fi

# Delete any existing instance of this printer
/usr/sbin/lpadmin -x "$printername"

# Now we can install the printer.
echo "Installing $printername..."

# options:
# -p destination          Specify/add the named destination
# -L location             Specify the textual location of the printer
# -D description          Specify the textual description of the printer
# -v device-uri           Specify the device URI for the printer
# -P ppd-file             Specify a PPD file for the printer

/usr/sbin/lpadmin \
        -p "$printername" \
        -L "$location" \
        -D "$gui_display_name" \
        -v "$address" \
        -P "$driver_ppd" \
        $options_global \
        $options_specific \
        -E

# Make this printer default.
if [[ $default_printer == "1" || $default_printer == "yes" ]]; then
    echo "Setting $printername as default..."
	/usr/bin/lpoptions -d "$printername"
fi

# Enable and start the printers on the system (after adding the printer initially it is paused).
echo "Starting $printername on the system..."
/usr/sbin/cupsenable "$(lpstat -p | grep -w "$printername" | awk '{print$2}')"
