#!/bin/bash

#Check if IP address argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <remote_ip>"
    exit 1
fi

#Set the path to the private key
KEY_PATH="$HOME/AhmadBaloum-vm2.pem"

REMOTE_IP=$1
NEW_KEY_NAME="new_key"
NEW_KEY_LOCATION="$HOME/$NEW_KEY_NAME"

#Generate a new SSH key pair
ssh-keygen -t rsa -b 4096 -f "$NEW_KEY_LOCATION" -N ""

#Backup the existing key pair
OLD_KEY_NAME="AhmadBaloum-vm2.pem"
OLD_KEY_LOCATION="$HOME/$OLD_KEY_NAME"
mv "$HOME/new_key" "$OLD_KEY_LOCATION"
mv "$HOME/new_key.pub" "$OLD_KEY_LOCATION.pub"

#Update SSH configuration to use the new key pair for the specific IP
echo -e "\nHost $REMOTE_IP" >> "$HOME/.ssh/config"
echo "    IdentityFile $KEY_PATH" >> "$HOME/.ssh/config"

#Distribute the new public key to the remote machine
ssh-copy-id -i "$NEW_KEY_LOCATION.pub" "$REMOTE_IP"

echo "SSH key rotation for $REMOTE_IP complete!"