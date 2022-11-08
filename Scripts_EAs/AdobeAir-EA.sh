#!/bin/bash

# Christoph von Gabler-Sahm (christoph.gabler-sahm@computacenter.com)
# Version 1.0
#
# Modified by Sam Novak (snovak@uwsp.edu) for AIR

# checks installed version of AIR Framework


# Plugin version
S_VERSION=$( /usr/bin/defaults read /Library/Frameworks/Adobe\ AIR.framework/Versions/Current/Resources/Info CFBundleVersion 2>/dev/null )


if [[ "${S_VERSION}" != "" ]]; then
    EA_RESULT="${S_VERSION}"
else
    EA_RESULT=""
fi

echo "<result>${EA_RESULT}</result>"