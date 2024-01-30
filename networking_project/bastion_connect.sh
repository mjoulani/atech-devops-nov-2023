#!/bin/bash

# Check if KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH env var is expected"
    exit 5
fi

# Start ssh-agent and add the key
eval "$(ssh-agent -s)"
ssh-add "$KEY_PATH"

# Check if the key was added successfully
if ! ssh-add -L &>/dev/null; then
    echo "Error: Failed to add the SSH key to ssh-agent. Please check your key and try again."
    exit 1
fi

# Check if bastion IP and private IP are provided
if [ $# -lt 1 ]; then
    echo "Please provide bastion IP address"
    exit 5
fi

# Extract bastion IP and private IP if provided
PUBLIC_IP=$1
PRIVATE_IP=$2

# Construct the SSH command based on the provided IPs
if [ -z "$PRIVATE_IP" ]; then
    # Case 2: Connect to the public instance
    ssh -i "$KEY_PATH" ubuntu@"$PUBLIC_IP"
else
    # Case 1 and Case 3: Connect to the private instance
    COMMAND=${@:3}  # Get all arguments starting from the third
    if [ -z "$COMMAND" ]; then
        # Case 1: Just connect to the private instance
        ssh -i "$KEY_PATH" -J "ubuntu@$PUBLIC_IP" ubuntu@"$PRIVATE_IP"
    else
        # Case 3: Run a command in the private instance
        ssh -i "$KEY_PATH" -J "ubuntu@$PUBLIC_IP" ubuntu@"$PRIVATE_IP" "$COMMAND"
    fi
fi
