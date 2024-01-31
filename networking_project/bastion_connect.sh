#!/bin/bash

# Check if the KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "Error: KEY_PATH environment variable not set. Please set the variable with the path to the SSH key."
    exit 1
fi

# Start ssh-agent and add the key
eval "$(ssh-agent -s)"
ssh-add "$KEY_PATH"

# Check if the key was added successfully
if ! ssh-add -L &>/dev/null; then
    echo "Error: Failed to add the SSH key to ssh-agent. Please check your key and try again."
    exit 1
fi

# Check the number of arguments
if [ "$#" -lt 1 ]; then
    echo "Please provide bastion IP address"
    exit 1
fi

# Public instance details
PUBLIC_INSTANCE_IP="$1"
PUBLIC_INSTANCE_USER="ubuntu"

# Private instance details
PRIVATE_INSTANCE_IP="$2"
PRIVATE_INSTANCE_USER="ubuntu"

# If private instance IP is provided, connect to the private instance
if [ "$#" -eq 2 ]; then
    # Connect to the private instance through the public instance
    ssh -q -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@"${PUBLIC_INSTANCE_IP}" -t "ssh -o StrictHostKeyChecking=no -i \$(echo \$New_Key) ubuntu@${PRIVATE_INSTANCE_IP}"
elif [ "$#" -eq 1 ]; then
    # Connect to the public instance
    ssh -i "$KEY_PATH" "${PUBLIC_INSTANCE_USER}@${PUBLIC_INSTANCE_IP}"
elif [ "$#" -eq 3 ]; then
    # Connect to the private instance and execute a command
    ssh -q -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@"${PUBLIC_INSTANCE_IP}" -t "ssh -o StrictHostKeyChecking=no -i \$(echo \$New_Key) ubuntu@${PRIVATE_INSTANCE_IP} $3"

else
    echo "Invalid usage"
    exit 1
fi

