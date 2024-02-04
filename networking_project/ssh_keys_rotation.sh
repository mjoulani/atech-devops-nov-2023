#!/bin/bash

# Ensure usage of the correct key path
if [[ -z "$KEY_PATH" ]]; then
  echo "Please set the KEY_PATH environment variable to the path of your private key."
  exit 1
fi


# Check if PUBLIC_IP and PRIVATE_IP are provided
if [ $# -lt 2 ]; then
    echo "Please provide public and private instance IP addresses"
    exit 5
fi

# Use descriptive and consistent variable names
new_key_path=./new_key 
new_key_pub_path=./new_key.pub

public_instance_ip="$1"
private_instance_ip="$2"


# Generate new SSH key pair with error handling
ssh-keygen -t rsa -b 4096 -N "" -f "$new_key_path" || {
  echo "Failed to generate SSH key pair."
  exit 1
}

#=====
# Copy the master key to the public instance
scp -i "$KEY_PATH" $KEY_PATH ubuntu@"$public_instance_ip":~/master_key.pem

scp -i "$KEY_PATH" "$new_key_pub_path" ubuntu@"$public_instance_ip":~/new_key.pub

echo "Step 2: Copying the public key to the authorized_keys file on the private instance via the public instance..."

# Copy the public key to the authorized_keys file on the private instance via the public instance
scp -o StrictHostKeyChecking=no -i "$KEY_PATH" "$new_key_pub_path" ubuntu@"$public_instance_ip":~/new_key.pub

echo "Step 3: Performing key rotation on the private instance..."

# Perform key rotation on the private instance
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" -A ubuntu@"$public_instance_ip" "bash -s" << EOF
    PRIVATE_IP="$private_instance_ip"
    KEY_PATH="~/master_key.pem"
    new_key_path=~/new_key 
    new_key_pub_path=~/new_key.pub

    # Copy the new public key to the private instance
    scp -o StrictHostKeyChecking=no -i "~/master_key.pem" "\$new_key_pub_path" ubuntu@\$PRIVATE_IP:$new_key_pub_path

    # Perform key rotation on the private instance
    ssh -o StrictHostKeyChecking=no -i "~/master_key.pem" ubuntu@\$PRIVATE_IP "cat $new_key_pub_path >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && rm -f $new_key_pub_path"

    echo "Keys on Public-instance rotated successfully."
EOF

#=====

# Check if keys have changed succefully then login with the new key
if [ "$KEY_PATH" != "$NEW_KEY_PATH" ]; then
    echo "Key rotation completed successfully."
    echo "New private key: $new_key_path"
    echo "New public key: $new_key_pub_path"
else
    echo "Keys have not changed. Rotation is not required."
fi

# Run bastion_connect.sh with the new key
./bastion_connect.sh  "$public_instance_ip" "$private_instance_ip"

