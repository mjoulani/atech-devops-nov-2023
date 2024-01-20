#!/bin/bash
set -x
# Checking if KEY_PATH env var is set
if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH env var is expected"
    exit 5
fi

# Taking arguments or input from command line with the script , in variables
public_instance_ip="$1"
private_instance_ip="$2"
command="$3"

# Checking if we have the public_instance_ip is set
if [ -z "$public_instance_ip" ]; then
    echo "Please provide bastion IP address"
    exit 5
fi

# Checking if we have private_instance_ip is set
if [ -z "$private_instance_ip" ]; then
   	ssh -i "$KEY_PATH" ubuntu@"$public_instance_ip"

# Checking command is avaible
elif [ -z "$command" ]; then
    # connects to the private instance, with overbastion host
    ssh -i "$KEY_PATH" ubuntu@"$public_instance_ip" ssh -t -t -i "~/.ssh/new_key" ubuntu@"$private_instance_ip"
else
    # connects to the private instance, over, and executes the command
	ssh -i "$KEY_PATH" ubuntu@"$public_instance_ip" ssh -t -t -i "~/.ssh/new_key" ubuntu@"$private_instance_ip" "$command"
fi
