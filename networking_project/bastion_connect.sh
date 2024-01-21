#!/bin/bash

# Check if KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "Error: KEY_PATH environment variable is not set."
    exit 5
fi

# Check if both public and private instance IPs are provided
if [ $# -lt 1 ] || [ $# -gt 3 ] ; then
    echo "Usage: $0 <public-instance-ip> [<private-instance-ip>]"
    exit 5
fi
#variables
public_instance_ip=$1
private_instance_ip=$2

if [ $# -eq 3 ]; then
  com=$3

fi

ssh_command="ssh -i $KEY_PATH "
#-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Connect to the public instance first and then to the private instance if provided
if [ -n "$private_instance_ip" ]; then
    $ssh_command ubuntu@$public_instance_ip "export KEY_PATH=Daniel-key.pem && ssh -i $KEY_PATH ubuntu@$private_instance_ip $com"
else
    $ssh_command ubuntu@$public_instance_ip
fi

# TODO your solution here