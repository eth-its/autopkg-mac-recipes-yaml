#!/bin/zsh

# $5 can contain multiple old passwords as comma-separated base64 values.
# $6 must contain one new password as a single base64 value.
# Example: $5="b2xkMQ==,b2xkMg==" and $6="bmV3UGFzc3dvcmQ="

if [[ -z "$4" || -z "$5" || -z "$6" ]]; then
    echo "Error: Missing required parameter(s): Admin User, Old Password, New Password."
    exit 1
fi

AdminUser="$4"
oldPasswordB64List=("${(@s:,:)5}")

if (( ${#oldPasswordB64List[@]} == 0 )); then
    echo "Error: No old password values provided in parameter 5."
    exit 1
fi

if [[ ! "$6" =~ ^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$ ]]; then
    echo "Error: Invalid base64 value for new password in parameter 6."
    exit 1
fi

if ! newAdminPassword="$(printf '%s' "$6" | base64 -D 2>/dev/null)"; then
    echo "Error: Failed to decode new password in parameter 6."
    exit 1
fi

# check if user exists
if ! id -u "$AdminUser" >/dev/null 2>&1; then
    echo "Error: Admin user '$AdminUser' does not exist."
    exit 1
fi


echo "Attempting to change password for: $AdminUser..."

password_changed=0
last_sysadminctl_output=""

for (( i=1; i<=${#oldPasswordB64List[@]} && i<=4; i++ )); do
    old_b64="${oldPasswordB64List[$i]}"

    if [[ -z "$old_b64" ]]; then
        echo "Error: Empty password entry found at position $i."
        exit 1
    fi

    if [[ ! "$old_b64" =~ ^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$ ]]; then
        echo "Error: Invalid base64 value for old password at position $i."
        exit 1
    fi

    if ! oldAdminPassword="$(printf '%s' "$old_b64" | base64 -D 2>/dev/null)"; then
        echo "Error: Failed to decode old password at position $i."
        exit 1
    fi

    # Change password
    sysadminctl_output=$(sysadminctl -adminUser "$AdminUser" -adminPassword "$oldAdminPassword" -resetPasswordFor "$AdminUser" -newPassword "$newAdminPassword" 2>&1)
    sysadminctl_rc=$?
    sysadminctl_has_error=0

    # sysadminctl may report logical failures in output while still returning rc=0.
    for error_pattern in "Error:" "Operation is not permitted without secure token unlock."; do
        if [[ "$sysadminctl_output" == *"$error_pattern"* ]]; then
            sysadminctl_has_error=1
            break
        fi
    done

    if (( sysadminctl_rc != 0 || sysadminctl_has_error )); then
        last_sysadminctl_output="$sysadminctl_output"
        continue
    fi

    # Verify the new password can actually authenticate.
    if ! dscl /Search -authonly "$AdminUser" "$newAdminPassword" >/dev/null 2>&1; then
        last_sysadminctl_output="Password verification failed after password change attempt at position $i."
        continue
    fi

    password_changed=1
    echo "Password changed successfully using old password at position $i."
    break
done

if (( password_changed == 0 )); then
    echo "Error: Failed to change password with the first 4 provided old passwords."
    if (( ${#oldPasswordB64List[@]} > 4 )); then
        echo "Info: Additional old password values after position 4 were ignored."
    fi
    if [[ -n "$last_sysadminctl_output" ]]; then
        printf '%s\n' "$last_sysadminctl_output"
    fi
        exit 1
fi

# If successful, print confirmation and check SecureToken status.
echo "Success: Password has been updated."
echo "Checking SecureToken status..."

securetoken_output=$(sysadminctl -secureTokenStatus "$AdminUser" 2>&1)
securetoken_rc=$?

# check SecureToken status command for errors
if [[ $securetoken_rc -ne 0 ]]; then
    echo "Error: Failed to read SecureToken status for user $AdminUser."
    [[ -n "$securetoken_output" ]] && printf '%s\n' "$securetoken_output"
    exit 1
fi

printf '%s\n' "$securetoken_output"