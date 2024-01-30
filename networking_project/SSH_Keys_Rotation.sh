#!/bin/bash

# Function to display error 
display_error() {
  echo "Error: $1"
  exit 1
}

# Check if the file not exist 
[ -z "$KEY_PATH" ] || [ ! -f "$KEY_PATH" ] && display_error "KEY_PATH environment variable is not set or points to a not exist file."

# Check if private instance IP is provided
[ $# -lt 1 ] && display_error "Please provide private instance IP address."

PRIVATE_IP=$1

# Generate new SSH key pair
ssh-keygen -t rsa -b 2048 -f new_key -N "" || display_error "Failed to generate new SSH key pair."

# Copy the new private key to the private instance
scp -i "$KEY_PATH" new_key "ubuntu@$PRIVATE_IP":~/new_key || display_error "Failed to copy the new private key to the private instance."

# Check if copying the new private key was successful
ssh -i "$KEY_PATH" "ubuntu@$PRIVATE_IP" "chmod 777 ~/new_key" || display_error "Failed to set permissions on the new private key."

# Copy the new public key to the private instance and append it to authorized_keys
scp -i "$KEY_PATH" new_key.pub "ubuntu@$PRIVATE_IP":~/new_key.pub || display_error "Failed to copy the new public key to the private instance."
ssh -i "$KEY_PATH" "ubuntu@$PRIVATE_IP" "cat ~/new_key.pub >> ~/.ssh/authorized_keys" || display_error "Failed to append the new public key to authorized_keys on the private instance."

echo "SSH key rotation completed successfully."
[ -f "$KEY_PATH" ] && rm "$KEY_PATH"

# Rename the new key
mv new_key "$KEY_PATH" || display_error "Failed to rename the new private key."

# Display the new key and public key files
ls -l ~

echo "Restarting bastion_connect.sh script"
./bastion_connect.sh "$BASTION_IP" "$PRIVATE_IP"
