#!/bin/bash


# TODO your solution here

# Check if KEY_PATH environment variable exists
if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH env var is expected"
    exit 5
fi

# Check for minimum number of arguments
if [ $# -lt 1 ]; then
    echo "Please provide bastion IP address"
    exit 5
fi

# Assign arguments to variables
BASTION_IP=$1
PRIVATE_IP=$2
COMMAND=$3

# Connect to the public instance only
if [ -z "$PRIVATE_IP" ]; then
    ssh -i "$KEY_PATH" ubuntu@"$BASTION_IP"
    exit 0
fi

# Connect to the private instance through the public instance
if [ -z "$COMMAND" ]; then
    ssh -i "$KEY_PATH" -o ProxyCommand="ssh -i $KEY_PATH -W %h:%p ubuntu@$BASTION_IP" ubuntu@"$PRIVATE_IP"
else
    # Run a command on the private instance
    ssh -i "$KEY_PATH" -o ProxyCommand="ssh -i $KEY_PATH -W %h:%p ubuntu@$BASTION_IP" ubuntu@"$PRIVATE_IP" "$COMMAND"
fi
