#!/bin/zsh
# shellcheck shell=bash
# shellcheck disable=SC2034,SC2296
# these are due to the dynamic variable assignments used in the localization strings

: << DOC
Run a jamf policy trigger specified in Parameter 4.
Silently quit to update if specified in Parameter 5.
Cancel if blocking apps are running specified in Parameters 6-11.
DOC

check_app_running() {
    # check if the application is running.
    # add .app to end of string if not supplied
    local app_name="$1"
    app_name="${app_name/\.app/}"            # remove any .app
    check_app_name="${app_name/\(/\\(}"       # escape any brackets for the pgrep
    check_app_name="${check_app_name/\)/\\)}"  # escape any brackets for the pgrep
    check_app_name="${check_app_name}.app"     # add the .app back
    if pgrep -f "/${check_app_name}" ; then
        echo "$check_app_name is running"
        app_running=1
    fi
}

silent_app_quit() {
    # silently kill the application.
    # add .app to end of string if not supplied
    local app_name="$1"
    app_name="${app_name/\.app/}"            # remove any .app
    check_app_name="${app_name/\(/\\(}"       # escape any brackets for the pgrep
    check_app_name="${check_app_name/\)/\\)}"  # escape any brackets for the pgrep
    check_app_name="${check_app_name}.app"     # add the .app back
    if pgrep -f "/${check_app_name}" ; then
        echo "Closing $check_app_name"
        /usr/bin/osascript -e "quit app \"$app_name\"" &
        sleep 1

        # double-check
        n=0
        while [[ $n -lt 10 ]]; do
            if pgrep -f "/$check_app_name" ; then
                (( n=n+1 ))
                sleep 1
				echo "Graceful close attempt # $n"
            else
                echo "$app_name closed."
                break
            fi
        done
        if pgrep -f "/$check_app_name" ; then
            echo "$check_app_name failed to quit - killing."
            /usr/bin/pkill -f "/$check_app_name"
        fi
    fi
}

## MAIN
app_running=0

# iterate through the blocking apps list

for (( i=6; i<=11; i++ )); do
    app_to_check="${(P)i}"
    # check that the parameter has been populated
    if [[ "$app_to_check" != "" && "$app_to_check" != "None" ]]; then
        if [[ $5 == "quit" ]]; then
            # quit the app if specified
            silent_app_quit "$app_to_check"
        else
            # exit the script if not set to quit
            check_app_running "$app_to_check"
            if [[ $app_running -eq 1 ]]; then
                echo "App $app_to_check is running so cancelling update"
                exit 0
            fi
        fi
    fi
done

sleep 3

# if we made it this far, we can run the install trigger
jamf policy -event "$4"
