#!/bin/bash

# Ensure the SSH key location is provided
if [ -z "${SSH_KEY}" ]; then
    echo "Environment variable SSH_KEY is required."
    exit 5
fi

# Initialize ssh-agent and add the SSH key
eval "$(ssh-agent -s)"
ssh-add "${SSH_KEY}"

# Verify if the SSH key has been added
if ! ssh-add -L > /dev/null; then
    echo "Error: Adding the SSH key failed. Please verify the key."
    exit 1
fi

# Verify that at least the bastion host IP is passed
if [ "$#" -lt 1 ]; then
    echo "Argument needed: <bastion-host-IP>"
    exit 5
fi

# Assign the first and second arguments as public and private IPs
BASTION_IP=$1
INTERNAL_IP=$2

# Form the SSH command
if [ -n "$INTERNAL_IP" ]; then
    # If private IP is provided, decide to connect or execute a command
    SSH_COMMAND=${@:3}  # Capture all arguments starting from the third
    if [ -n "$SSH_COMMAND" ]; then
        # If there are additional commands, execute them on the internal instance
        ssh -i "${SSH_KEY}" -J ubuntu@"${BASTION_IP}" ubuntu@"${INTERNAL_IP}" "${SSH_COMMAND}"
    else
        # Otherwise, just initiate an SSH connection to the internal instance
        ssh -i "${SSH_KEY}" -J ubuntu@"${BASTION_IP}" ubuntu@"${INTERNAL_IP}"
    fi
else
    # If only bastion IP is provided, connect to the public instance
    ssh -i "${SSH_KEY}" ubuntu@"${BASTION_IP}"
fi
