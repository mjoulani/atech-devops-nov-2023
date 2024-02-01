#!/bin/bash
#old fasion connection without jump but you must export keypath on public server and copy the master keypath
# Check if KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "Error: KEY_PATH environment variable is not set."
    exit 5
fi
ssh_command="ssh -i $KEY_PATH  -t -q -o StrictHostKeyChecking=no"
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
    $ssh_command ubuntu@$public_instance_ip "ssh -o StrictHostKeyChecking=no ubuntu@$private_instance_ip -i $(echo \$KEY_PATH) "
    ;;

  3)
    com=$3
    $ssh_command ubuntu@$public_instance_ip "ssh -o StrictHostKeyChecking=no ubuntu@$private_instance_ip -i $(echo \$KEY_PATH)  $com"
    ;;

  *)
    STATEMENTS
    ;;
esac



# TODO your solution here