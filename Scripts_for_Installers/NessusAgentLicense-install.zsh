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

# all output from now on is written also to a log file
logfile="/Library/Logs/ethz-nessus-status.log"
exec > >(tee "${logfile}") 2>&1

# files
launchdaemon="/Library/LaunchDaemons/ch.ethz.nessus.plist"
retry_script="/Library/Management/ETHZ/Nessus/nessus-link.zsh"
mkdir -p "/Library/Management/ETHZ/Nessus"

# reset the existing launchdaemon if present
if [[ -f "$launchdaemon" ]]; then
    /bin/launchctl stop ch.ethz.nessus
    /bin/launchctl unload "$launchdaemon"
    /bin/rm "$launchdaemon"
fi

# check agent status
link_connection=$(/Library/NessusAgent/run/sbin/nessuscli agent status | grep "Linked to:" | sed 's|Linked to: ||')
if [[ "$link_connection" != "None" ]]; then
    echo "[$(date)] Agent is linked."
    exit 0
else
    # run the command
    if /Library/NessusAgent/run/sbin/nessuscli agent link --key="$nessus_key" --host="$nessus_host" --port="$nessus_port" --name="$(hostname)" --groups="$nessus_group"; then
        echo "[$(date)] License successfully applied"
    else
        echo "[$(date)] ERROR: License file not applied"
    fi
    # check again
    link_connection=$(/Library/NessusAgent/run/sbin/nessuscli agent status | grep "Linked to:" | sed 's|Linked to: ||')
    if [[ "$link_connection" != "None" ]]; then
        echo "[$(date)] Agent is linked."
        exit 0
    fi
fi

if [[ -f "$retry_script" ]]; then
    rm "$retry_script"
fi

cat > "$retry_script" <<'END' 
#!/bin/zsh

# input variables
nessus_host="$1"
nessus_port="$2"
nessus_key="$3"
nessus_group="$4"

logfile="/Library/Logs/ethz-nessus-status.log"
launchdaemon="/Library/LaunchDaemons/ch.ethz.nessus.plist"

# check agent status

if [[ $(/Library/NessusAgent/run/sbin/nessuscli agent status | grep "Linked to:" | sed 's|Linked to: ||') == "None" ]]; then
    # try to link again if no link
    if /Library/NessusAgent/run/sbin/nessuscli agent link --key="$3" --host="$1" --port="$2" --name="$(hostname)" --groups="$4" >> "$logfile"; then
        echo "[$(date)] License successfully applied" >> "$logfile"
        # remove the launchdaemon
        if [[ -f "$launchdaemon" ]]; then
            echo "[$(date)] Removing $launchdaemon" >> "$logfile"
            /bin/launchctl unload -F "$launchdaemon"
            if /bin/rm "$launchdaemon"; then
                echo "[$(date)] $launchdaemon removed" >> "$logfile"
            else
                echo "[$(date)] $launchdaemon was not removed" >> "$logfile"
            fi
        fi
    else
        echo "[$(date)] ERROR: License file not applied (from LaunchDaemon)" >> "$logfile"
    fi
fi
END

if [[ -f "$retry_script" ]]; then
    /usr/sbin/chown root:wheel "$retry_script"
    /bin/chmod 755 "$retry_script"
    echo "[$(date)] Link script written to $retry_script"
else
    echo "[$(date)] Error: $retry_script not found"
    exit 1
fi


# Create the launchdaemon
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
        <string>/bin/zsh</string>
        <string>$retry_script</string>
        <string>$nessus_host</string>
        <string>$nessus_port</string>
        <string>$nessus_key</string>
        <string>$nessus_group</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
END

# wait for 2 seconds
sleep 2

# adjust permissions correctly then load.
/usr/sbin/chown root:wheel "$launchdaemon"
/bin/chmod 755 "$launchdaemon"

if /bin/launchctl load "$launchdaemon"; then
    if /bin/launchctl start ch.ethz.nessus; then
        echo "[$(date)] LaunchDaemon started."
    else
        echo "[$(date)] ERROR: LaunchDaemon failed to start."
        exit 1
    fi
else
    echo "[$(date)] ERROR: LaunchDaemon load failed."
    exit 1
fi
