#!/bin/zsh
if [ ! -d /Library/Management/ETHZ/Scripts ] ; then mkdir -p /Library/Management/ETHZ/Scripts ; fi
cat <<'EOT'>/Library/Management/ETHZ/Scripts/toggle-ethernet.sh
#!/bin/zsh
sleep 2 # give the OS some time to boot
default_iface=$(route get 1.1|grep interface|awk {'print $2'})
#check if wifi is primary - if yes, abort. 
/usr/sbin/networksetup -getairportpower ${default_iface}>/dev/null
if [ $? -eq 0 ] ; then echo "airport is primary,exiting" ; exit 0 ; fi
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