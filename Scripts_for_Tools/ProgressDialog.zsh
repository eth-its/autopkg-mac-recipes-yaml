#!/bin/zsh

# This script will pop up a mini dialog with progress of a jamf pro policy

# source https://github.com/bartreardon/swiftDialog-scripts/blob/main/JamfSelfService/jss-progress.sh

jamf_pid=""
jamf_log="/var/log/jamf.log"
dialog_log=$(mktemp /var/tmp/dialog.XXX)
chmod 644 ${dialog_log}
script_log="/var/tmp/jamfprogress.log"
count=0
# Location of this script
progress_script_location="/Library/Management/ETHZ/Progress"
lock_file="$progress_script_location/lock.txt"

function update_log() {
    echo "$(date) ${1}" >> $script_log
}

function dialog_cmd() {
    echo "${1}" >> "${dialog_log}"
    sleep 0.1
}

function launch_dialog() {
	update_log "launching main dialog"
    open -a "/Library/Application Support/Dialog/Dialog.app" --args --mini --title "${policy_name}" --icon "${icon}" --message "Please wait for the installation to complete.  \nYou may need to restart the application afterwards." --progress 8 --commandfile "${dialog_log}"
    update_log "main dialog running in the background with PID $PID"
}

function dialog_error() {
	update_log "launching error dialog"
    errormsg="### Error\n\nSomething went wrong. Please contact IT support and report the following error message:\n\n${1}"
    open -a "/Library/Application Support/Dialog/Dialog.app" --args --ontop --title "Jamf Policy Error" --icon "${icon}" --overlayicon caution --message "${errormsg}"
    update_log "error dialog running in the background with PID $PID"
}

function quit_script() {
	update_log "quit_script was called"
    dialog_cmd "quit: "
    sleep 1
    update_log "Exiting"
    # brutal hack - need to find a better way
    killall tail
    if [[ -e ${dialog_log} ]]; then
        update_log "removing ${dialog_log}"
		rm "${dialog_log}"
    fi
    rm -f "$lock_file"
    exit 0
}

function read_jamf_log() {
    update_log "Starting jamf log read"    
    if [[ "${jamf_pid}" ]]; then
        update_log "Processing jamf pro log for PID ${jamf_pid}"
        while read -r line; do    
            status_line=$(echo "${line}")
            case "${status_line}" in
                *Success*)
                    if [[ "${status_line}" == *"$jamf_pid"* ]]; then
                        update_log "Success"
                        dialog_cmd "progresstext: Complete"
                        dialog_cmd "progress: complete"
                        sleep 2
                        dialog_cmd "quit: "
                        update_log "Success Break"
                        quit_script
                    fi
                ;;
                *failed*)
                    if [[ "${status_line}" == *"$jamf_pid"* ]]; then
                        update_log "Failed"
                        dialog_cmd "progresstext: Policy Failed"
                        dialog_cmd "progress: complete"
                        sleep 2
                        dialog_cmd "quit: "
                        dialog_error "${status_line}"
                        update_log "Error Break"
                        #break
                        quit_script
                    fi
                ;;
                *"Removing existing launchd task"*)
                    if [[ "${status_line}" == *"$jamf_pid"* ]]; then
                        update_log "Launchd task removed"
                        dialog_cmd "progresstext: Launchd task was removed"
                        dialog_cmd "progress: complete"
                        sleep 2
                        dialog_cmd "quit: "
                        update_log "Ambiguous Break"
                        #break
                        quit_script
                    fi
                ;;
                *"Executing Policy"*)
                    # running a trigger so we need to switch to the new PID
                    jamf_pid=$( awk -F"[][]" '{print $2}' <<< "$status_line" )
                    progresstext=$(echo "${status_line}" | awk -F "]: " '{print $NF}')
                    update_log "Reading policy entry : ${progresstext}"
                    dialog_cmd "progresstext: ${progresstext}"
                    dialog_cmd "progress: increment"
                ;;
                *)
                    progresstext=$(echo "${status_line}" | awk -F "]: " '{print $NF}')
                    update_log "Reading policy entry : ${progresstext}"
                    dialog_cmd "progresstext: ${progresstext}"
                    dialog_cmd "progress: increment"
                ;;
            esac
            ((count++))
            if [[ ${count} -gt 10 ]]; then
                update_log "Hit maxcount"
                dialog_cmd "progress: complete"
                sleep 0.5
                #break
                quit_script
            fi
        done < <(tail -f -n1 $jamf_log) 
    else
        update_log "Something went wrong"
        echo "ok, something weird happened. We should have a PID but we don't."
    fi
    update_log "End while loop"
}

function main() {
    update_log "***** Start *****"
    if [[ -f "$lock_file" ]]; then
        # script is already running or crashed
        exit
    fi

    # write lockfile to prevent this script doing anything twice
    touch "$lock_file"
    last_log_entry=$(tail -n 1 "$jamf_log")
    if [[ "$last_log_entry" == *"Executing Policy"* ]]; then
        update_log "Running launch_dialog function"
        update_log "Getting Policy Name"
        policy_name=$( sed 's|^.*Executing Policy ||' <<< "$last_log_entry" )
        launch_dialog
        update_log "Getting Policy ID"
        jamf_pid=$( awk -F"[][]" '{print $2}' <<< "$last_log_entry" )
        if [[ $jamf_pid ]]; then
            update_log "Policy ID is ${jamf_pid}"
        fi
        update_log "Processing Jamf Log"
        read_jamf_log
        update_log "All Done we think"
        update_log "***** End *****"
    fi
    quit_script
}

main 
exit 0