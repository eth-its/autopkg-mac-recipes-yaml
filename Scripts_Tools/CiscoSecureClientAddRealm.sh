#!/bin/bash

#######################################################################
# Configure a Cisco Secure Client realm
#######################################################################

if [[ $4 ]]; then
    realm="$4"
elif [[ $1 ]]; then
    realm="$1"
else
    echo "This script requires a parameter for the realm"
    exit
fi
hostaddress="%HOST%"
hostname="$hostaddress/$realm"
outputfile="/opt/cisco/secureclient/vpn/profile/$realm.xml"

cat > "$outputfile" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<AnyConnectProfile xmlns="http://schemas.xmlsoap.org/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.xmlsoap.org/encoding/ AnyConnectProfile.xsd">
	<ClientInitialization>
		<UseStartBeforeLogon UserControllable="true">false</UseStartBeforeLogon>
		<AutomaticCertSelection UserControllable="false">true</AutomaticCertSelection>
		<ShowPreConnectMessage>false</ShowPreConnectMessage>
		<CertificateStore>All</CertificateStore>
		<CertificateStoreMac>All</CertificateStoreMac>
		<CertificateStoreOverride>true</CertificateStoreOverride>
		<ProxySettings>Native</ProxySettings>
		<AllowLocalProxyConnections>true</AllowLocalProxyConnections>
		<AuthenticationTimeout>12</AuthenticationTimeout>
		<AutoConnectOnStart UserControllable="true">false</AutoConnectOnStart>
		<MinimizeOnConnect UserControllable="true">true</MinimizeOnConnect>
		<LocalLanAccess UserControllable="true">true</LocalLanAccess>
		<DisableCaptivePortalDetection UserControllable="true">false</DisableCaptivePortalDetection>
		<ClearSmartcardPin UserControllable="false">true</ClearSmartcardPin>
		<IPProtocolSupport>IPv4,IPv6</IPProtocolSupport>
		<AutoReconnect UserControllable="false">true
			<AutoReconnectBehavior UserControllable="false">DisconnectOnSuspend</AutoReconnectBehavior>
		</AutoReconnect>
		<AutoUpdate UserControllable="false">true</AutoUpdate>
		<RSASecurIDIntegration UserControllable="false">Automatic</RSASecurIDIntegration>
		<WindowsLogonEnforcement>SingleLocalLogon</WindowsLogonEnforcement>
		<WindowsVPNEstablishment>LocalUsersOnly</WindowsVPNEstablishment>
		<AutomaticVPNPolicy>false</AutomaticVPNPolicy>
		<PPPExclusion UserControllable="false">Disable
			<PPPExclusionServerIP UserControllable="false"></PPPExclusionServerIP>
		</PPPExclusion>
		<EnableScripting UserControllable="false">false</EnableScripting>
		<EnableAutomaticServerSelection UserControllable="false">false
			<AutoServerSelectionImprovement>20</AutoServerSelectionImprovement>
			<AutoServerSelectionSuspendTime>4</AutoServerSelectionSuspendTime>
		</EnableAutomaticServerSelection>
		<RetainVpnOnLogoff>false
		</RetainVpnOnLogoff>
		<AllowManualHostInput>true</AllowManualHostInput>
	</ClientInitialization>
	<ServerList>
		<HostEntry>
			<HostName>$hostname</HostName>
			<HostAddress>$hostaddress</HostAddress>
			<UserGroup>$realm</UserGroup>
		</HostEntry>
	</ServerList>
</AnyConnectProfile>
EOF

cat "$outputfile"
