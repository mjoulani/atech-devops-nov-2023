#!/bin/bash

# Check if KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "Error: KEY_PATH environment variable is not set."
    exit 5
fi

# Public and Private instance details
PUBLIC_INSTANCE_IP=$1
PRIVATE_INSTANCE_IP=$2
command=$3
INSTANCE_USER="ubuntu"
#USER2="ec2-user"

# SSH connection commands
ssh_command="ssh -t -i $KEY_PATH -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"


#valoidate the public instance input is provided
if [ -z "$PUBLIC_INSTANCE_IP" ]; then
    echo "pulic ip is needed"
    exit 5
fi

if [ -n "$PRIVATE_INSTANCE_IP" ]; then
	findkey="find . -type f -name new_key"
	NEW_KEY_PATH=$($ssh_command $INSTANCE_USER@$PUBLIC_INSTANCE_IP "$findkey" | tr -d '\r')
	if [ -z "$NEW_KEY_PATH" ]; then
	# New key is found, update KEY_PATH
		NEW_KEY_PATH=$KEY_PATH
	fi
fi
#ssh_command2="ssh -i $NEW_KEY_PATH -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
ssh_command2="ssh -i $NEW_KEY_PATH "

if [ "$#" -eq 1 ]; then
# Connect only to the public instance
    $ssh_command $INSTANCE_USER@$PUBLIC_INSTANCE_IP

elif [ "$#" -eq 2 ]; then
# Connect to the private instance via the public instance
  $ssh_command $INSTANCE_USER@$PUBLIC_INSTANCE_IP $ssh_command2 $INSTANCE_USER@$PRIVATE_INSTANCE_IP
elif [ "$#" -eq 3 ]; then
  echo "done"
# If a command is provided, execute it
  $ssh_command $INSTANCE_USER@$PUBLIC_INSTANCE_IP $ssh_command2 $INSTANCE_USER@$PRIVATE_INSTANCE_IP "$command"
# Exit without waiting for the command to finish
   # exit 0
fi

# Exit with the same status as the last command (SSH to private instance)
exit $?
