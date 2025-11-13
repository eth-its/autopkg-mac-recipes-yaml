#!/bin/zsh
if [ ! -d /Library/Management/ETHZ/Scripts ] ; then mkdir -p /Library/Management/ETHZ/Scripts ; fi
cat <<'EOT'>/Library/Management/ETHZ/Scripts/toggle-ethernet.sh
#!/bin/zsh
#script to toggle primary wired interface once, very soon after boot

#uncomment the following two lines for debug info
#set -x
#exec &>>/tmp/ch.ethz.ethernet-toggle.log

# wait for network to be up, for a max of max_tries, in increments of retry_delay seconds; abort if still offline
max_tries=6
retry_delay=2

. /etc/rc.common
CheckForNetwork
c=0
while [[ "${NETWORKUP}" != "-YES-"  && $c -lt $max_tries ]]
do
        sleep $retry_delay
        NETWORKUP=
        CheckForNetwork
        ((c++))
done
if [[ "${NETWORKUP}" != "-YES-" ]] ; then ; echo "network still down after $((max_tries * retry_delay)) sec, exiting" ; exit 0 ; fi

# wait for default route to be available - sometimes rc.common is a bit premature
c=0
while [[ $(route get 1.1|grep interface &>/dev/null; echo $?) -gt 0 && $c -lt $max_tries ]]
do
        echo "waiting for default route.."
        sleep $retry_delay
        ((c++))
done
if [[ $(route get 1.1|grep interface &>/dev/null; echo $?) -gt 0 ]] ; then ; echo "no default route available after $((max_tries * retry_delay)) sec, exiting" ; exit 0 ; fi

#check if wifi is primary - if yes, retry after 5 seconds delay, if wifi is still primary, then abort.
default_iface=$(route get 1.1|grep interface|awk {'print $2'})
/usr/sbin/networksetup -getairportpower ${default_iface}>/dev/null
if [ $? -eq 0 ] ; then 
	echo "airport is primary,trying again after 5 seconds" 
        sleep 5
        default_iface=$(route get 1.1|grep interface|awk {'print $2'})
        /usr/sbin/networksetup -getairportpower ${default_iface}>/dev/null
        if [ $? -eq 0 ] ; then echo "airport still primary after 5 seconds, aborting" ; exit 0 ; fi 
fi

sleep $retry_delay

#get more info on network service
hardware_ports=$(/usr/sbin/networksetup -listallhardwareports)
port_service_name=$(echo ${hardware_ports}|grep -B1 ${default_iface}|head -n1|sed -e 's/.*\: //')
#toggle the interface
/usr/sbin/networksetup -setnetworkserviceenabled ${port_service_name} off
/sbin/ifconfig ${default_iface} down
sleep 2
/usr/sbin/networksetup -setnetworkserviceenabled ${port_service_name} on
/sbin/ifconfig ${default_iface} up
EOT
chown root:wheel /Library/Management/ETHZ/Scripts/toggle-ethernet.sh
chmod 0700 /Library/Management/ETHZ/Scripts/toggle-ethernet.sh

cat <<'EOF'>/Library/LaunchDaemons/ch.ethz.toggle-ethernet.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>ch.ethz.toggle-ethernet</string>
    <key>LaunchOnlyOnce</key>
    <true/>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>/Library/Management/ETHZ/Scripts/toggle-ethernet.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
chown root:wheel /Library/LaunchDaemons/ch.ethz.toggle-ethernet.plist
chmod 644 /Library/LaunchDaemons/ch.ethz.toggle-ethernet.plist