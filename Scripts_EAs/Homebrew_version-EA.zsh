#!/bin/zsh

intel_brew="/usr/local/bin/brew"
arm_brew="/opt/homebrew/bin/brew"

if [ -f "$arm_brew" ]; then
    result=$($arm_brew --version | tr -d 'Homebrew ')
elif [ -f "$intel_brew" ]; then
    result=$($intel_brew --version | tr -d 'Homebrew ')
else
    result="None"
fi

echo "<result>$result</result>"
