#!/bin/zsh

#########################################################
# CIS removal               							#
# created by Philippe Scholl                            #
# version 1		    								    #
# copyright by Mac Product Center                       #
#########################################################


# revert cis os_unlock_active_user_session_disable
/usr/bin/security authorizationdb write system.login.screensaver "use-login-window-ui"

# sudo timeout revert
/usr/bin/find /etc/sudoers* -type f -exec sed -i '' '/timestamp_timeout/d' '{}' \;

# wake on lan reset
/usr/bin/pmset -c womp 1

sleep 3

exit 0