#!/bin/zsh
#ensure install directory
if [ ! -d /Library/Management/ETHZ/Scripts ] ; then mkdir -p /Library/Management/ETHZ/Scripts ; fi

#unpack reenumerate ( thanks https://github.com/nanoscopic/macos_usbdev_reset )
reenumerate='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'
printf $reenumerate|base64 -D|gunzip - >/Library/Management/ETHZ/Scripts/reenumerate
chmod 0700 /Library/Management/ETHZ/Scripts/reenumerate

#unpack script triggered at bootup, by launchd
cat <<'EOT'>/Library/Management/ETHZ/Scripts/toggle-ethernet.sh
#!/bin/zsh
#script to toggle primary wired interface once, very soon after boot
# provided following conditions are met : 
# the device is - connected via ethernet ; - that has a dns server that self-resolves to $triggerdomain ; - that is unable to ping $testhostname
# when the device is connected via builtin adapter, the script toggles the network interface via networksetup, which restores eapolclient functionality
# if it's a non-builtin adapter, the USB device is told to reinitialize via "reenumerate", which leads to eapolclient being relaunched

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

echo "Test address $testhostname unavailable, toggling network interface required."
echo "IP addresses of interface before toggle: "
ifconfig $default_iface|grep inet|awk {'print $2'} 

if [[ $internal -gt 0 ]] && [[ $usbnic -eq 1 ]]  ; then
  echo "Toggling USB Reenumeration to reinitialise USB Ethernet adapter"
  usbnic_productid=$(plutil -p /Library/Preferences/SystemConfiguration/NetworkInterfaces.plist|grep -A10 $default_iface|grep "idProduct"|awk {'print $3'}|xargs printf "0x%x") 
  usbnic_vendorid=$(plutil -p /Library/Preferences/SystemConfiguration/NetworkInterfaces.plist|grep -A10 $default_iface|grep "idVendor"|awk {'print $3'}|xargs printf "0x%x") 
  /Library/Management/ETHZ/Scripts/reenumerate $usbnic_productid $usbnic_vendorid
  if [[ $? == 0 ]] ; then echo "Reinitialisation accepted" ; else echo "Reinitialisation failed" ; fi
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

#unpack launchdaemon,ensure permissions ; launchd will run at next startup.
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