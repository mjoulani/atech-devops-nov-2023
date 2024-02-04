#!/bin/bash

# Set the path to the SSH key
export KEY_PATH="$HOME/.ssh/yo-key-pair.pem"

# Check if the KEY_PATH variable is set
if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH env var is expected"
    exit 5
fi

#command line arguments
public_instance_ip="$1"
private_instance_ip="$2"
command_to_run="${3}"


# Check if the public_instance_ip variable is not provided
if [ -z "$public_instance_ip" ]; then
    echo "Please provide bastion IP address"
    exit 5
fi

# Check if both private_instance_ip and command_to_run are provided
if [ -n "$private_instance_ip" ]; then
    if [ -n "$command_to_run" ]; then
        # SSH into the public instance and then SSH into the private instance
	ssh -t -i "$KEY_PATH" ubuntu@"$public_instance_ip" "ssh -i \$KEY_PATH ubuntu@$private_instance_ip -tt $command_to_run"
    else
        # SSH into the public instance and then into the private instance
        ssh -t -i "$KEY_PATH" ubuntu@"$public_instance_ip" ssh -t -i \$KEY_PATH ubuntu@$private_instance_ip
    fi
else
    # SSH only into the public instance
    ssh -i "$KEY_PATH" ubuntu@"$public_instance_ip"
fi
