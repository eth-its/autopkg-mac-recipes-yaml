#!/bin/zsh
#ensure install directory
if [ ! -d /Library/Management/ETHZ/Scripts ] ; then mkdir -p /Library/Management/ETHZ/Scripts ; fi

#ensure rosetta - Thanks Graham !
if [[ "$(/usr/bin/arch)" == "arm64"* ]]; then
    echo "[Rosetta-2-install] This is an arm64 Mac."
    # is Rosetta 2 installed?
    if /usr/bin/pgrep oahd >/dev/null 2>&1 ; then
        echo "[Rosetta-2-install] Rosetta 2 is already installed"
    else
        echo "[Rosetta-2-install] Rosetta 2 is missing - installing"
        echo
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        echo 
        if /usr/bin/pgrep oahd >/dev/null 2>&1 ; then
            echo "[Rosetta-2-install] Rosetta 2 is now installed"
        else
            echo "[Rosetta-2-install] Rosetta 2 installation failed"
            exit 1
        fi
    fi
else
    echo "[Rosetta-2-install] This is an Intel Mac."
fi

#unpack reenumerate ( thanks apple ca. 2011; sourced from USB Prober.app Version 4.4.5 )
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
  /Library/Management/ETHZ/Scripts/reenumerate $usbnic_vendorid,$usbnic_productid -v
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