#!/bin/zsh
# shellcheck shell=bash

: <<DOC
Runs the Nessus Agent CLI command to link the agent to the server

Required parameters:
4 - Nessus agent host name
5 - Nessus agent port
6 - License key
7 - Group
DOC

# input variables
nessus_host="$4"
nessus_port="$5"
nessus_key="$6"
nessus_group="$7"

# get hostname
hostname="$(hostname)"

# logfile
logfile="/var/log/ethz-nessus-status.log"

# run the command
if /Library/NessusAgent/run/sbin/nessuscli agent link --key="$nessus_key" --host="$nessus_host" --port="$nessus_port" --name="$hostname" --groups="$nessus_group"; then
    echo "[$(date)] License successfully applied" > "$logfile"
else
    echo "[$(date)] ERROR: License file not applied" > "$logfile"
    exit 1
fi

# check if the agent is linked
link_connection=$(/Library/NessusAgent/run/sbin/nessuscli agent status | grep "Linked to:" | sed 's|Linked to: ||')
# if not linked, write a script that will try again and create a launchdaemon. The script should remove the launchdaemon once the connection is successful.
if [[ "$link_connection" == "None" ]]; then
    echo "[$(date)] License file not applied, setting up LaunchDaemon" > "$logfile"
    retry_script_location="/Library/Management/ETHZ/Nessus"
    retry_script="$retry_script_location/nessus-link.zsh"
    mkdir -p "$retry_script_location"

    # reset the existing launchdaemon if present
    if [[ -f "$launchdaemon" ]]; then
        /bin/launchctl bootout "$launchdaemon" ||:
        /bin/rm "$launchdaemon"
    fi

    cat > "$retry_script" <<END 
#!/bin/zsh

# file locations
logfile="/var/log/ethz-nessus-status.log"
launchdaemon="/Library/LaunchDaemons/ch.ethz.nessus.plist"

# check agent status
link_connection=$(/Library/NessusAgent/run/sbin/nessuscli agent status | grep "Linked to:" | sed 's|Linked to: ||')

if [[ "$link_connection" == "None" ]]; then
    # try to link again if no link
    if /Library/NessusAgent/run/sbin/nessuscli agent link --key="$nessus_key" --host="$nessus_host" --port="$nessus_port" --name="$hostname" --groups="$nessus_group"; then
        echo "[$(date)] License successfully applied, removing LaunchDaemon"
        # remove the launchdaemon
        if [[ -f "$launchdaemon" ]]; then
            /bin/launchctl bootout "$launchdaemon" ||:
            /bin/rm "$launchdaemon"
        fi
    else
        echo "[$(date)] ERROR: License file not applied"
    fi
fi
END

    # Create the launchdaemon
    launchdaemon="/Library/LaunchDaemons/ch.ethz.nessus.plist"
    cat > "$launchdaemon" <<END 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Disabled</key>
	<false/>
	<key>Label</key>
	<string>ch.ethz.nessus</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/bash</string>
		<string>$retry_script</string>
	</array>
    <key>StartInterval</key>
    <integer>180</integer>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
END

    # wait for 2 seconds
    sleep 2

    # adjust permissions correctly then load.
    /usr/sbin/chown root:wheel "$launchdaemon"
    /bin/chmod 644 "$launchdaemon"

    /bin/launchctl enable system/ch.ethz.nessus
    /bin/launchctl bootstrap system "$launchdaemon"
else
    echo "[$(date)] Agent is linked."
fi