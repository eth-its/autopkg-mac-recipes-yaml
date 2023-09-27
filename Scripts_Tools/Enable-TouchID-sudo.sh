#!/bin/zsh
# shellcheck shell=bash

: <<DOC
Enable TouchID for sudo
by Graham Pugh

from https://github.com/flammable/enable_sudo_touchid/blob/master/munki_postinstall_script.sh
and https://sixcolors.com/post/2023/08/in-macos-sonoma-touch-id-for-sudo-can-survive-updates/
DOC

enable_touchid="auth       sufficient     pam_tid.so"

# check for sonoma
if [[ -f /etc/pam.d/sudo_local.template ]]; then

    # check for an existing local sudo file
    if [[ ! -f /etc/pam.d/sudo_local ]]; then
        cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
    fi

    # ensure the touchid line is not commented out
    /usr/bin/sed -i '' -e "s/\#${enable_touchid}/${enable_touchid}/" /etc/pam.d/sudo_local
else
    # method for older OS
    /usr/bin/sed -i '' -e "1s/^//p; 1s/^.*/${enable_touchid}/" /etc/pam.d/sudo
fi
