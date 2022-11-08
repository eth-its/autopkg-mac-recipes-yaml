#!/bin/bash
# enable touch id for sudo
# from https://github.com/flammable/enable_sudo_touchid/blob/master/munki_postinstall_script.sh

enable_touchid="auth       sufficient     pam_tid.so"

/usr/bin/sed -i '' -e "1s/^//p; 1s/^.*/${enable_touchid}/" /etc/pam.d/sudo
