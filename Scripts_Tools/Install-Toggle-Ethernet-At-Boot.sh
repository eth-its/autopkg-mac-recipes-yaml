#!/bin/zsh
if [ ! -d /Library/Management/ETHZ/Scripts ] ; then mkdir -p /Library/Management/ETHZ/Scripts ; fi
cat <<'EOT'>/Library/Management/ETHZ/Scripts/toggle-ethernet.sh
#!/bin/zsh
#script to toggle primary wired interface once, very soon after boot
# provided following conditions are met : 
# the device is - connected via ethernet ; - that has a dns server that self-resolves to $triggerdomain ; - that is unable to ping $testhostname
# when the device is connected via builtin adapter, the script toggles the network interface via networksetup, which restores eapolclient functionality
# if it's a non-builtin adapter, the device is sent to sleep mode, after an automatic wakeup one second after shutdown/sleep is configured

triggerdomain=ethz.ch
testhostname=d.ethz.ch

#uncomment the following two lines for debug info
set -x
exec &>>/tmp/ch.ethz.ethernet-toggle.log

# wait for network to be up, for a max of max_tries, in increments of retry_delay seconds; abort if still offline
max_tries=6
retry_delay=2

##### NO CONFIGURATION AFTER THIS LINE #####

. /etc/rc.common
CheckForNetwork
c=0
while [[ "${NETWORKUP}" != "-YES-"  && $c -lt $max_tries ]]
do
        echo "network not yet available, retrying in $retry_delay seconds"
        sleep $retry_delay
        NETWORKUP=
        CheckForNetwork
        ((c++))
done
if [[ "${NETWORKUP}" != "-YES-" ]] ; then ; echo "network still down after $((max_tries * retry_delay)) sec, exiting" ; exit 0 ; fi
echo "network now up, checking for default route"

#wait for default route to be available
c=0
while [[ $(route get 1.1|grep interface &>/dev/null; echo $?) -gt 0 && $c -lt $max_tries ]] ; do
echo "waiting for route to be available, retrying in $retry_delay seconds"
sleep $retry_delay
((c++))
done
if [[ $(route get 1.1|grep interface &>/dev/null; echo $?) -gt 0 ]] ; then ; echo "default route still unavailable after $((max_tries * retry_delay)) sec, exiting" ; exit 0 ; fi
echo "default route found"

#for good measure .. 
sleep $retry_delay

#check whether wifi is primary interface - if so, retry after 2 times retry_delay seconds delay. If wifi is still primary, then abort. 
#Wifi seems to connect more quickly than ethernet in some cases.
default_iface=$(route get 1.1|grep interface|awk {'print $2'})
/usr/sbin/networksetup -getairportpower ${default_iface}>/dev/null
if [ $? -eq 0 ] ; then 
	echo "Wi-Fi is primary network interface,trying again after $(( 3*retry_delay )) seconds" 
        sleep $(( 3*retry_delay ))
        default_iface=$(route get 1.1|grep interface|awk {'print $2'})
        /usr/sbin/networksetup -getairportpower ${default_iface}>/dev/null
        if [ $? -eq 0 ] ; then echo "Wi-Fi still primary after $(( 3*retry_delay )) seconds, aborting" ; exit 0 ; fi 
fi

#get more info on the primary network service - device name and network service name
hardware_ports=$(/usr/sbin/networksetup -listallhardwareports)
port_service_name=$(echo ${hardware_ports}|grep -B1 ${default_iface}|head -n1|sed -e 's/.*\: //')

#determine DNS on the ethernet card, and check if it self-identifies as being part of $triggerdomain ; if not, exit
dnsip=$(scutil --dns|grep -B4 $default_iface|grep nameserver|awk {'print $3'}|head -n1)

#ipv6 DNS does not always react well when asked about itself; so we rely no the default resolver, while for ipv4 we ask the server itself 
if [[ ${dnsip} == *':'* ]] ; then
  internal=$(nslookup $dnsip|grep .$triggerdomain|wc -l)
else 
  internal=$(nslookup $dnsip $dnsip|grep .$triggerdomain|wc -l)
fi

if [[ $internal -eq 0 ]] ; then echo "Ethernet DNS not in $triggerdomain ; exiting" ; exit 0 ; fi

#check whether macOS thinks this is a builtin Ethernet card
usbnic=$(plutil -p /Library/Preferences/SystemConfiguration/NetworkInterfaces.plist|grep -A10 $default_iface|grep '"IOBuiltin" => false'|wc -l)

#check whether $testhostname is reachable ; if yes, network is ok and we can exit
internaldnsavailable=$(ping -q $testhostname -c 2 &>/dev/null ; echo $?)
if [[ $internaldnsavailable -eq 0 ]] ; then echo "$testhostname reachable, network ok, exiting"; exit 0 ; fi  

echo "Test address unavailable, toggling network interface required."
echo "IP addresses of interface before toggle: "
ifconfig $default_iface|grep inet|awk {'print $2'} 

if [[ $internal -gt 0 ]] && [[ $usbnic -eq 1 ]]  ; then
  echo "Sending Mac to sleep and auto-wakeup ASAP after to reinitialise USB Ethernet adapter"
  pmset relative wake 1
  pmset sleepnow
  echo "woke up after sleeping, exiting" 
else
  #toggle the interface 
  echo "Toggling built-in Ethernet interface"
  /usr/sbin/networksetup -setnetworkserviceenabled ${port_service_name} off
  /sbin/ifconfig ${default_iface} down
  sleep $retry_delay
  /usr/sbin/networksetup -setnetworkserviceenabled ${port_service_name} on
  /sbin/ifconfig ${default_iface} up
  echo "Toggled built-in Ethernet interface,exiting"
fi
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