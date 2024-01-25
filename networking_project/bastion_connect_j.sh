#!/bin/bash

# Check if KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "Error: KEY_PATH environment variable is not set."
    exit 5
fi
ssh_command="ssh -i $KEY_PATH "
# Check if both public and private instance IPs are provided
if [ $# -lt 1 ] || [ $# -gt 3 ] ; then
    echo "Usage: $0 <public-instance-ip> [<private-instance-ip>] command"
    exit 5
fi

public_instance_ip=$1
private_instance_ip=$2
case $# in

  1)
    $ssh_command ubuntu@$public_instance_ip
    ;;

  2)
    $ssh_command -J ubuntu@$public_instance_ip ubuntu@$private_instance_ip
    ;;

  3)
    com=$3
    $ssh_command -J ubuntu@$public_instance_ip ubuntu@$private_instance_ip $com
    ;;

  *)
    STATEMENTS
    ;;
esac



# TODO your solution here