
#!/bin/bash

# Validate the presence of the KEY_PATH environment variable
if [ -z "$KEY_PATH" ]; then
    echo "Error: Please set the KEY_PATH environment variable."
    exit 5
fi

# Ensure both public and private IP addresses are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 PUBLIC_IP PRIVATE_IP"
    exit 5
fi

# Assign the first and second arguments to respective variables
PUBLIC_IP=$1
PRIVATE_IP=$2
NEW_KEY_NAME="new_ssh_key"

echo "Starting key update process..."

# Generate a new SSH key without a passphrase
ssh-keygen -t rsa -b 2048 -f "$NEW_KEY_NAME" -q -N "" || { echo "Key generation failed"; exit 1; }

# Transfer the existing key to the public server
scp -i "$KEY_PATH" -o StrictHostKeyChecking=no master_key.pem ubuntu@"$PUBLIC_IP":~/ || { echo "Failed to transfer master_key.pem to public server"; exit 1; }

# Copy the new public key to the public server
scp -i "$KEY_PATH" -o StrictHostKeyChecking=no "$NEW_KEY_NAME.pub" ubuntu@"$PUBLIC_IP":~/ || { echo "Failed to transfer new public key to public server"; exit 1; }

echo "Updating keys on the private server..."
# Append the new public key to the private server's authorized_keys via the public server
ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@"$PUBLIC_IP" "cat $NEW_KEY_NAME.pub | ssh -o StrictHostKeyChecking=no ubuntu@$PRIVATE_IP 'cat >> ~/.ssh/authorized_keys' && echo 'Public key updated on private server.'" || { echo "Failed to update public key on private server"; exit 1; }

# Clean up the keys from the public server
ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@"$PUBLIC_IP" "rm ~/master_key.pem ~/new_ssh_key.pub" || { echo "Failed to clean up keys on public server"; exit 1; }

# Test the new connection to the public server with the new key
echo "Testing connection to the public server with the new key..."
ssh -i "$NEW_KEY_NAME" -o StrictHostKeyChecking=no ubuntu@"$PUBLIC_IP" "echo 'Connection test successful.'" || { echo "Connection test failed"; exit 1; }

# Output the result
if [ -f "$NEW_KEY_NAME" ]; then
    echo "Key update completed. New keys are stored at $NEW_KEY_NAME and $NEW_KEY_NAME.pub"
else
    echo "Key update failed."
fi

# Run bastion_connect.sh with the new key
if [ -x "./bastion_connect.sh" ]; then
    echo "Running bastion_connect.sh with the new key..."
    ./bastion_connect.sh "$NEW_KEY_NAME" "$PUBLIC_IP" "$PRIVATE_IP"
else
    echo "Error: bastion_connect.sh not found or is not executable."
    exit 1
fi

echo "Script execution completed."




