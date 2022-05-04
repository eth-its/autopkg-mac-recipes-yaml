#!/bin/zsh
# shellcheck shell=bash

: <<DOC
Runs the Nessus Agent CLI command to link the agent to the server

Required parameters:
4 - Nessus agent host name
5 - Nessus agent port
6 - License key
7 - Group
DOC

# input variables
nessus_host="$4"
nessus_port="$5"
nessus_key="$6"
nessus_group="$7"

# get hostname
hostname="$(hostname)"

# run the command
if /Library/NessusAgent/run/sbin/nessuscli agent link --key="$nessus_key" --host="$nessus_host" --port="$nessus_port" --name="$hostname" --groups="$nessus_group"; then
    echo "License successfully applied"
else
    echo "ERROR: License file not applied"
    exit 1
fi
