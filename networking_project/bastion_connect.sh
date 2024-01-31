#!/bin/bash
if [[ -z "$KEY_PATH" ]]; then
	echo "KEY_PATH env var is expected"
	exit 5
fi

if [ $# -lt 1 ]; then
	echo "Please provide bastion IP address"
	exit 5

elif [ $# -gt 3 ]; then
	echo "Too much args!"
	exit 5
fi

PUBLIC_IP=$1

if [ $# -ge 2 ]; then
	# Connect to the private instance
	
	command=$3
	PRIVATE_IP=$2
	ssh -o ProxyCommand="ssh -W %h:%p ubuntu@$PUBLIC_IP -i $KEY_PATH" -i $KEY_PATH ubuntu@"$PRIVATE_IP" $command
else
	# Connect to the public instance
	ssh -i "$KEY_PATH" ubuntu@"$PUBLIC_IP"
fi