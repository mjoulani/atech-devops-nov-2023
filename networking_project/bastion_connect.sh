#!/bin/bash

export KEY_PATH="$HOME/.ssh/yo-key-pair.pem"

if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH env var is expected"
    exit 5
fi

public_instance_ip="$1"
private_instance_ip="$2"
command_to_run="${3}"

echo $command_to_run "COMMMAND"

if [ -z "$public_instance_ip" ]; then
    echo "Please provide bastion IP address"
    exit 5
fi

if [ -n "$private_instance_ip" ]; then
    if [ -n "$command_to_run" ]; then
        ssh -t -i "$KEY_PATH" ubuntu@"$public_instance_ip" "ssh -i \$KEY_PATH ubuntu@$private_instance_ip -tt $command_to_run"
    else
        echo "HEREEEEEEEEEEEEEE"
        ssh -t -i "$KEY_PATH" ubuntu@"$public_instance_ip" ssh -t -i \$KEY_PATH ubuntu@$private_instance_ip
    fi
else
    ssh -i "$KEY_PATH" ubuntu@"$public_instance_ip"
fi
