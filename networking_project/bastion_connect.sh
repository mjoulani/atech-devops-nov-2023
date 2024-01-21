#!/bin/bash

export Key_PATH="/ssh/yo-key-pair.pem"

if [ -z "$Key_PATH" ]; then
    echo "Key_PATH is not set. Exiting."
    exit 5
fi

public_instance_ip="$1"
private_instance_ip="$2"
bastion_ip="$3"
command_to_run="${@:4}"

if [ -z "$public_instance_ip" ] || [ -z "$private_instance_ip" ] || [ -z "$bastion_ip" ]; then
    echo "Please provide public_instance_ip, private_instance_ip, and bastion_ip."
    exit 1
fi

if [ -z "$command_to_run" ]; then
    echo "Please provide a command to run on the private instance."
    exit 1
fi

if [ "$#" -eq 4 ]; then
    ssh -i "$Key_PATH" ubuntu@"$public_instance_ip" ssh -i /home/ubuntu/ssh/server2-private.pem ubuntu@"$private_instance_ip" -t "$command_to_run"
elif [ "$#" -eq 3 ]; then
    ssh -i "$Key_PATH" ubuntu@"$public_instance_ip"
else
    echo "Invalid number of arguments."
    exit 1
fi
