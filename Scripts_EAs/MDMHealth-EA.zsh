#!/bin/zsh

filename=/private/var/tmp/EA-$(basename "$0").result
#cache output in a file, only run commands once every 24h to prevent excess load on clients
if [[ -f ${filename} ]] ; then
  if [[ $(cat ${filename}|grep -c '<result>') -eq 1 ]] ; then  
    if [[ $(stat -f "%Sm" -t "%s" ${filename}) -gt $(( $(date +%s) - 24*3600 )) ]] ; then cat ${filename} ; exit 0 ; fi 
  fi
fi

report() {
echo "<result>$@</result>" | tee ${filename}
exit 0
}

# ServerURL populated 
profileURL=$(system_profiler SPConfigurationProfileDataType | grep "ServerURL" | cut -d'"' -f2)
if [[ -z "$profileURL" ]]; then ; report "No_MDM_Profile_found" ; fi

# Does the system consider itself enrolled 
enrolledState=$(/usr/bin/profiles status -type enrollment | grep "MDM enrollment" | cut -d ' ' -f3)
if [[ $enrolledState == "No" ]]; then ; report "Profiles_reports_No_Enrolment" ; fi

# MDM Identity present in Keychain
missingIdentityCount=$(command log show --style=syslog --last 2h --predicate 'subsystem == "com.apple.ManagedClient" && eventMessage CONTAINS[c] "The specified item is no longer valid. It may have been deleted from the keychain."' | grep -c " It may have been deleted from the keychain.")
if [[ "$missingIdentityCount" -gt 0 ]]; then ; report "MDM_identity_missing" ; fi

# Keychain-Identities - assume issued by jamf+not expired=okay
identities=($(security find-identity -v /Library/Keychains/System.keychain | awk '{print $3}' | tr -d '"'))
now_seconds=$(date +%s)
for i in $identities; do
  certificate=$(security find-certificate -c "$i")
  issuer=$(echo ${certificate} | grep issu)
  if [[ ${issuer:l} == *"jss built-in certificate authority"* ]]; then
    expiry=$(security find-certificate -c "$i" -p | openssl x509 -noout -enddate | cut -f2 -d"=")
    date_seconds=$(date -j -f "%b %d %T %Y %Z" "$expiry" +%s)
    if (( date_seconds < now_seconds )); then ; report "MDM_identity_expired" ; else break ; fi
  fi
done

report Healthy