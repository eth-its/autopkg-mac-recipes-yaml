#!/bin/bash

# Script for Jamf Pro to create a new user and ask for the password interactively.
# Parameters are optional - dialog boxes will ask if these fields are missing

# Parameter 4 - short user name (account name)
# Parameter 5 - full name (display name)
# Parameter 6 - "admin" to create an admin account
# Parameter 7 - minimum characters for password
# Parameter 8 - password complexity: none/complex
#               complex: must have small, large, numeral, special
# Parameter 9 - set SecureToken for the new user. Admin credentials of a valid
#               account will be requested

# Short name (i.e. account name and home directory name)
AccountShortName="$4"
# Full / Long Name (used for display purposes so can be changed after account creation)
AccountFullName="$5"
# Admin or standard account
AccountType="$6"
# Minimum password length - must be a number
MinPasswordLength="$7"
# Password Complexity
PasswordComplexity="$8"

# enable SecureToken - this will add the user to FileVault. Requires
# SkipAskForAdmin to be "yes" and real admin credentials of a FileVault-enabled
# user to be supplied
AddSecureToken="$9"

askForShortName () {
    $osascript <<EOT
        set nameentry to text returned of (display dialog "Please enter the new account name (shortname)" default answer "" buttons {"Enter"} default button 1 with icon 2)
EOT
}

askForFullName () {
    $osascript <<EOT
        set nameentry to text returned of (display dialog "Please enter the Full name (long name)" default answer "" buttons {"Enter"} default button 1 with icon 2)
EOT
}

askForPassword () {
    $osascript <<EOT
        set nameentry to text returned of (display dialog "Please enter a password for the $AccountShortName account" default answer "" with hidden answer buttons {"Enter"} default button 1 with icon 2)
EOT
}

verifyPassword () {
    $osascript <<EOT
        set nameentry to text returned of (display dialog "Please re-enter the password for the $AccountShortName account" default answer "" with hidden answer buttons {"Enter"} default button 1 with icon 2)
EOT
}

passwordsDontMatch () {
    return=$(osascript <<-EOF
    tell application "System Events" to display dialog "Passwords did not match! Please try again" buttons {"OK", "Try again"} default button 2 with icon 2
EOF
)
    # Check status of osascript
    if [[ "$return" == "button returned:OK" ]] ; then
       echo "User aborted. Exiting..."
       exit 1
    fi
}

adminUserHasNoSecureToken () {
    return=$(osascript <<-EOF
    tell application "System Events" to display dialog "$AdminUser does not have a SecureToken so cannot add another user. Please try a different admin user" buttons {"OK", "Try again"} default button 2 with icon 2
EOF
)
    # Check status of osascript
    if [[ "$return" == "button returned:OK" ]] ; then
       echo "User aborted. Exiting..."
       exit 1
    fi
}

passwordTooShort () {
    $osascript <<EOT
        display dialog "Password is too short! Please try again" buttons {"OK"} default button 1 with icon 2
EOT
}

passwordTooSimple () {
    $osascript <<EOT
        display dialog "Password is too simple! Please try again" buttons {"OK"} default button 1 with icon 2
EOT
}

userExists () {
    $osascript <<EOT
        display dialog "User already exists" buttons {"OK"} default button 1 with icon 2
EOT
}

askForAdmin () {
    $osascript <<EOT
        set nameentry to text returned of (display dialog "Please enter an administrator account" default answer "" buttons {"Enter"} default button 1 with icon 2)
EOT
}

askForAdminPw () {
    $osascript <<EOT
        set nameentry to text returned of (display dialog "Please the password for the $AdminUser account" default answer "" with hidden answer buttons {"Enter"} default button 1 with icon 2)
EOT
}

askForAdminOrStandard () {
    $osascript <<EOT
        set nameentry to the button returned of (display dialog "Select whether the $AccountShortName account should have Standard or Administrator rights" buttons {"Standard", "Administrator"} default button 1 with icon 2)
EOT
}

askToAddSecureToken () {
    $osascript <<EOT
        set nameentry to the button returned of (display dialog "Select whether the $AccountShortName account should be enabled in FileVault" buttons {"Yes", "No"} default button 1 with icon 2)
EOT
}


createAccount(){
    # Find out the next available free user IDs
    MAXID=$($dscl . -list /Users UniqueID | $awk '{print $2}' | $sort -ug | $tail -1)

    if [ $MAXID -ge 500 ]; then
        $echo "Existing User ID bigger than 500 found. MAXID = $MAXID"
    else
        MAXID=500
        $echo "Existing User ID smaller than 500 found. MAXID = $MAXID"
    fi

    AccountUID=$((MAXID+1))

    echo "Creating account $AccountShortName"
    if [[ $AccountType == "admin" ]]; then
        $sysadminctl -addUser $AccountShortName -UID $AccountUID -fullName "$AccountFullName" -password $AccountPassword -home /Users/$AccountShortName -$adminFlag -adminUser $AdminUser -adminPassword $AdminPassword -admin
    else
        $sysadminctl -addUser $AccountShortName -UID $AccountUID -fullName "$AccountFullName" -password $AccountPassword -home /Users/$AccountShortName -$adminFlag -adminUser $AdminUser -adminPassword $AdminPassword
    fi

    if [[ $AddSecureToken == "Yes" ]]; then
        echo "Adding SecureToken so that user can unlock FileVault"
        $sysadminctl -secureTokenOn $AccountShortName -password $AccountPassword -adminUser $AdminUser -adminPassword $AdminPassword
    fi

    # Report user creation in log
    $echo "Account successfully created:"
    $echo "ID:         $AccountUID"
    $echo "Full Name:  $AccountFullName"
    $echo "Short Name: $AccountShortName"
}

complexityCheck() {
    # code thanks to https://www.linuxquestions.org/questions/linux-server-73/bash-script-to-test-string-complexity-like-password-complexity-807370/
    readonly re_digit='[[:digit:]]'
    readonly re_lower='[[:lower:]]'
    readonly re_punct='[[:punct:]]'
    readonly re_space='[[:space:]]'
    readonly re_upper='[[:upper:]]'

    score=0
    for re in "$re_digit" "$re_lower" "$re_punct" "$re_space" "$re_upper"
    do
        [[ $1 =~ $re ]] && let score++
    done
    echo $score
}

## Main

# commands
sysadminctl="/usr/sbin/sysadminctl"
awk="/usr/bin/awk"
sort="/usr/bin/sort"
tail="/usr/bin/tail"
echo="/bin/echo"
dscl="/usr/bin/dscl"
id="/usr/bin/id"
osascript="/usr/bin/osascript"
dseditgroup="/usr/sbin/dseditgroup"
fdesetup="/usr/bin/fdesetup"
grep="/usr/bin/grep"

# check validity of password length check
case $MinPasswordLength in
    ''|*[!0-9]*)
        echo "Invalid minimum password length string. Setting to default (4)"
        MinPasswordLength=4
        ;;
    *) echo "Minimum password length set to $MinPasswordLength" ;;
esac

# check passowrd complexity setting
case $PasswordComplexity in
    complex)
        echo "Complex password check mode selected."
        ;;
    *)
        echo "Simple password complexity mode selected."
        PasswordComplexity="none"
        ;;
esac

# get account name (short name)
if [[ $AccountShortName == "" ]]; then
    AccountShortName=$(askForShortName)
fi

if $id "$AccountShortName" >/dev/null 2>&1; then
    echo "$AccountShortName Account already exists: skipping"
    userExists
    exit 0
fi

# get full name
if [[ $AccountFullName == "" ]]; then
    AccountFullName=$(askForFullName)
fi

# get a password
PasswordsMatch=0
while [[ $PasswordsMatch = 0 ]]; do
    AccountPassword=$(askForPassword)
    # check password length
    if [ ${#AccountPassword} -lt $MinPasswordLength ]; then
        echo "Password length ${#AccountPassword} is less than the allowed minimum ($MinPasswordLength)"
        passwordTooShort
        continue
    else
        echo "Password length OK"
    fi

    # check password complexity
    if [[ $PasswordComplexity == "complex" ]]; then
        score=$(complexityCheck "$AccountPassword")
        if [[ $score -lt 3 ]]; then
            echo "Password is not complex enough (score is $score)."
            passwordTooSimple
            continue
        fi
    fi

    PasswordVerify=$(verifyPassword)
    if [[ "$AccountPassword" != "$PasswordVerify" ]]; then
        passwordsDontMatch
    else
        PasswordsMatch=1
        break
    fi
done

# set account type
case $AccountType in
    admin|Admin|administrator|Administrator)
        echo "Administrator account type selected."
        AccountType="admin"
        ;;
    standard|Standard)
        echo "Standard account type selected."
        AccountType=""
        ;;
    *)
        AccountTypeChoice=$(askForAdminOrStandard)
        echo "$AccountTypeChoice account type selected"
            if [[ $AccountTypeChoice == "Administrator" ]]; then
                AccountType="admin" 
            else
                AccountType=""
            fi
        ;;
esac

# add SecureToken if set
if [[ $AddSecureToken == "yes" ]]; then
    AddSecureToken="Yes"
elif [[ $AddSecureToken != "no" ]]; then
    AddSecureToken=$(askToAddSecureToken)
fi
# check if this user has a SecureToken if relevant
if [[ $AddSecureToken == "Yes" ]]; then
    # Ask for an admin user
    AdminUser=$(askForAdmin)
    echo "Checking if admin user has a SecureToken"
    userHasSecureToken=0
    while [[ $userHasSecureToken = 0 ]]; do
        if $fdesetup list | $grep $AdminUser ; then
            userHasSecureToken=1
            break
        fi
        adminUserHasNoSecureToken
        AdminUser=$(askForAdmin)
    done
    # now ask for the admin password
    AdminPassword=$(askForAdminPw)
else
    # if we don't want to add a SecureToken it's better to provide fake credentials
    AdminUser=random
    AdminPassword=alsorandom
    AddSecureToken=no
fi

# create the account
createAccount

# end