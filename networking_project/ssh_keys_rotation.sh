#!/bin/bash

if [ -z "$1" ]; then
    echo "Please provide bastion IP address"
    exit 5
fi

if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH environment variable is expected"
    exit 5
fi

#KEY_PATH=$KEY_PATH
NEW_KEY_PATH=~/new_key
NEW_KEY_PUB_PATH=~/new_key.pub

# Generate a new RSA key pair
ssh-keygen -t rsa -b 2048 -f "$NEW_KEY_PATH" -N ""
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to generate RSA key pair."
    exit 1
fi

# Copy the new public key to the authorized_keys file on the remote server
scp -i "$KEY_PATH" "$NEW_KEY_PUB_PATH" "ubuntu@$1:~/.ssh/authorized_keys"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to copy public key to remote server."
    exit 1
fi

ssh -i "$NEW_KEY_PATH" "ubuntu@$1"

if [ $? -eq 0 ]; then
    echo "Key rotation successful."
else
    echo "Key rotation failed. Please check and try again."
fi