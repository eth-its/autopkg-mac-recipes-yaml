#!/bin/zsh

### Install Wolfram Mathematica if not present
if [[ ! -d /Applications/Wolfram.app ]] ; then 
echo "Wolfram Mathematica not installed! Running Jamf trigger"
/usr/local/bin/jamf policy -event "Wolfram Mathematica-install"
fi

### Install Wolfram/Mathematica node License
umask 002

license_server="$4"
license_string="$5"
license_type="$6"

host=$(hostname)

mathpass_fileloc="/Library/Wolfram/Licensing/mathpass"
mkdir -p "$(dirname $mathpass_fileloc)"

if [[ -f "$mathpass_fileloc" ]]; then
    mv "$mathpass_fileloc" "$mathpass_fileloc.bak"
fi
echo '!'"$license_server" | tee "$mathpass_fileloc"

