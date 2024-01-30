#!/bin/bash

# Check if KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH env var is expected"
    exit 5
fi

# Check if PUBLIC_IP and PRIVATE_IP are provided
if [ $# -lt 2 ]; then
    echo "Please provide public and private instance IP addresses"
    exit 5
fi

PUBLIC_IP="$1"
PRIVATE_IP="$2"
NEW_KEY_PATH=./new_key


echo "Step 1: Generating a new SSH key pair..."
# Generate a new SSH key pair
ssh-keygen -f "$NEW_KEY_PATH" -N ""

# Copy the master key to the public instance
scp -i "$KEY_PATH" master_key.pem ubuntu@"$PUBLIC_IP":~/master_key.pem

scp -i "$KEY_PATH" "$NEW_KEY_PATH.pub" ubuntu@"$PUBLIC_IP":~/new_key.pub

echo "Step 2: Copying the public key to the authorized_keys file on the private instance via the public instance..."
# Copy the public key to the authorized_keys file on the private instance via the public instance
scp -o StrictHostKeyChecking=no -i "$KEY_PATH" "$NEW_KEY_PATH.pub" ubuntu@"$PUBLIC_IP":~/new_key.pub

echo "Step 3: Performing key rotation on the private instance..."
# Perform key rotation on the private instance
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" -A ubuntu@"$PUBLIC_IP" "bash -s" << EOF
    PRIVATE_IP="$PRIVATE_IP"
    KEY_PATH="$KEY_PATH"
    NEW_KEY_PATH=~/new_key

    # Copy the new public key to the private instance
    scp -o StrictHostKeyChecking=no -i "$KEY_PATH" "\$NEW_KEY_PATH.pub" ubuntu@\$PRIVATE_IP:~/new_key.pub

    # Perform key rotation on the private instance
    ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@\$PRIVATE_IP "cat ~/new_key.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && rm -f ~/new_key.pub"

    echo "Keys on Public-instance rotated successfully."
EOF

# Delete master key from public instance
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@"$PUBLIC_IP" "rm -f ~/master_key.pem"
# Delete new key from public instance
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@"$PUBLIC_IP" "rm -f ~/new_key.pub"

# Check if keys have changed and if login with the new key is successful
if [ "$KEY_PATH" != "$NEW_KEY_PATH" ]; then
    echo "Key rotation completed successfully."
    echo "New private key: $NEW_KEY_PATH"
    echo "New public key: $NEW_KEY_PATH.pub"
else
    echo "Keys have not changed. Rotation is not required."
fi

# Run bastion_connect.sh with the new key
./bastion_connect.sh  "$PUBLIC_IP" "$PRIVATE_IP"