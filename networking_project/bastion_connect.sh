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
    scp -i "$KEY_PATH" -p "$KEY_PATH" ubuntu@"$public_instance_ip":/home/ubuntu/old_key
   	ssh -i "$KEY_PATH" ubuntu@"$public_instance_ip"
# Checking command is avaible
elif [ -z "$command" ]; then
    # connects to the private instance, with overbastion host
    status=$(ssh -i "$KEY_PATH" ubuntu@"$public_instance_ip" ls /home/ubuntu/new_key | wc -l )
    if [ $status = "1" ]; then
        ssh -t -i "$KEY_PATH" ubuntu@"$public_instance_ip" ssh -i "/home/ubuntu/new_key" ubuntu@"$private_instance_ip"
    else
        scp -i "$KEY_PATH" -p "$KEY_PATH" ubuntu@"$public_instance_ip":/home/ubuntu/old
        ssh -t -i "$KEY_PATH" ubuntu@"$public_instance_ip" ssh -i "/home/ubuntu/old_key" ubuntu@"$private_instance_ip"
    fi
else
    status=$(ssh -i "$KEY_PATH" ubuntu@"$public_instance_ip" ls /home/ubuntu/new_key | wc -l )
    # connects to the private instance, over, and executes the command
    if [ $status = "1" ]; then
        ssh -t -i "$KEY_PATH" ubuntu@"$public_instance_ip" ssh -i "/home/ubuntu/new_key" ubuntu@"$private_instance_ip" "$command"
    else 
        scp -i "$KEY_PATH" -p "$KEY_PATH" ubuntu@"$public_instance_ip":/home/ubuntu/old_key
        ssh -t -i "$KEY_PATH" ubuntu@"$public_instance_ip" ssh -i "/home/ubuntu/old_key" ubuntu@"$private_instance_ip" "$command"
    fi
fi
