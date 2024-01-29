#!/bin/bash

CMD="$3"

# Check if the KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "Error: KEY_PATH environment variable not set. Please set the variable with the path to the SSH key."
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

# If private instance IP is provided, connect to the private instance
if [ "$#" -eq 2 ]; then
    PRIVATE_INSTANCE_IP="$2"
    PRIVATE_INSTANCE_USER="ubuntu"

    # Connect to the private instance through the public instance
    ssh -i "$KEY_PATH" -J "${PUBLIC_INSTANCE_USER}@${PUBLIC_INSTANCE_IP}" "${PRIVATE_INSTANCE_USER}@${PRIVATE_INSTANCE_IP}"
elif [ "$#" -eq 1 ]; then
    # Connect to the public instance
    ssh -i "$KEY_PATH" "${PUBLIC_INSTANCE_USER}@${PUBLIC_INSTANCE_IP}"
elif [ "$#" -eq 3 ]; then
    # Connect to the private instance and execute a command
    ssh -i "$KEY_PATH" "${PUBLIC_INSTANCE_USER}@${PUBLIC_INSTANCE_IP}" "ssh -i WaseemKeyPair.pem ubuntu@10.1.1.105 '$3'"
else
    echo "Invalid usage"
    exit 1
fi

