#!/bin/bash


# TODO your solution here
export Key_PATH=~/.ssh/server1-youssef-carmi-key.pem

if [ -z "${Key_PATH}" ]; then
    echo "Variable 'Key_PATH' is not set. Exiting."
    exit 5  # Exit with code 5
fi

public_instance_ip=$1
private_instance_ip=$2
command_to_private_instance=$3


if [ "$#" -eq 1 ]; then

    ssh -i "$Key_PATH" ubuntu@"$public_instance_ip"
    exit 0

elif [ "$#" -eq 2 ]; then
    
    ssh -i "$Key_PATH" ubuntu@"$public_instance_ip" ssh -i /home/ubuntu/new_key ubuntu@"$private_instance_ip"
    exit 0
elif [ "$#" -eq 3 ]; then
    
    ssh -i "$Key_PATH" ubuntu@"$public_instance_ip" ssh -i /home/ubuntu/new_key ubuntu@"$private_instance_ip" -t "$command_to_private_instance; /bin/bash"    
    exit 0
else
echo "Please provide bastion IP address"
exit 
fi
