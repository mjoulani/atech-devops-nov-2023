#!/bin/bash

# check if KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "Error: KEY_PATH environment variable not set. Please set KEY_PATH and try a>
    exit 5
fi

# function to connect to the private instance
connect_to_private_instance() {
    public_ip=$1
    private_ip=$2

    # Check if both public and private IPs are provided
    if [ -z "$public_ip" ] || [ -z "$private_ip" ]; then
        echo "Error: Both public and private instance IPs are required."
        exit 5
    fi

    # Connect to the private instance
    ssh -i $KEY_PATH ubuntu@$public_ip  ssh -i new_key.pem ubuntu@$private_ip #/bin/b>
}

# function to connect to the public instance
connect_to_public_instance() {
    public_ip=$1

    # check if public IP is provided
    if [ -z "$public_ip" ]; then
        echo "Error: Public instance IP is required."
        exit 5
    fi

    # Connect to the public instance
    ssh -i $KEY_PATH ubuntu@$public_ip
}
