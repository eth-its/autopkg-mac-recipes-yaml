#!/bin/zsh

intel_brew="/usr/local/bin/brew"
arm_brew="/opt/homebrew/bin/brew"

if [ -f "$arm_brew" ]; then
    result=$($arm_brew --prefix)
elif [ -f "$intel_brew" ]; then
    result=$($intel_brew --prefix)
else
    result=""
fi

echo "<result>$result</result>”
