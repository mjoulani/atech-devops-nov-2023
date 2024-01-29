#!/bin/bash

# Check if KEY_PATH is set
if [ -z "$KEY_PATH" ]; then
  echo "ERROR: KEY_PATH variable is not set."
  exit 1
fi

# Check if private instance IP is provided as an argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <private-instance-ip> , Please provide IP address"
  exit 1
fi

private_instance_ip=$1
new_key_path=~/new_key

# Generate a new SSH key pair
ssh-keygen -f "$new_key_path" -t rsa -N '' <<< "y" 1> /dev/null

# Copy the public key to the private instance using scp
if [ ! -f "$new_key_path.pub" ]; then
  echo "ERROR: Failed to generate the new public key."
  exit 1
fi

chmod 600 "$new_key_path.pub"

# Use scp to copy the public key to authorized_keys on the private instance
scp -o StrictHostKeyChecking=no -i "$KEY_PATH" "$new_key_path.pub" "ubuntu@$private_instance_ip:~/.ssh/authorized_keys" 1> /dev/null 2> /dev/null

# If scp fails, exit with an error
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to copy the public key to the authorized_keys file on the private instance."
  exit 1
fi

# Update the KEY_PATH variable with the new private key path
export KEY_PATH="$new_key_path"

# Clean up old keys
rm -f "$KEY_PATH.pub"

echo "Key rotation completed."
