#!/bin/zsh

intel_brew="/usr/local/bin/brew"
arm_brew="/opt/homebrew/bin/brew"

localusername=$(dscl . -search /Users UniqueID 501|awk '/UniqueID/ {print $1}')

if [ -f "$arm_brew" ]; then
    result=$(sudo -u $localusername zsh -c "$arm_brew --version | tr -d 'Homebrew '")
elif [ -f "$intel_brew" ]; then
    result=$(sudo -u $localusername zsh -c "$intel_brew --version | tr -d 'Homebrew '")
else
    result="None"
fi

echo "<result>$result</result>"
