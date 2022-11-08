#!/bin/bash

# Check Active Directory Bind Status
# https://www.jamf.com/jamf-nation/discussions/25234/command-line-to-check-for-ad-bind

# ping the Domain or DC


# If the ping was successful
if ping -c 3 -o %FQDN% 1> /dev/null 2> /dev/null ; then
    # Check the domain returned with dsconfigad
    domain=$( dsconfigad -show | awk '/Active Directory Domain/{print $NF}' )
    # If the domain is correct
    if [[ "$domain" == "%FQDN%" ]]; then
        # If the check was successful...
        if id -u %KNOWN_USER% 1> /dev/null 2> /dev/null ; then
            echo "<result>Bound</result>"
        else
            # If the check failed
            echo "<result>Out of range of DC</result>"
        fi
    else
        # If the domain returned did not match our expectations
        echo "<result>Unbound</result>"
    fi
else
    echo "<result>Out of range of DC</result>"
fi

exit 0