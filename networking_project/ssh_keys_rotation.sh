#!/bin/bash

# Read the private IP address from the command-line argument
private_ip=$1
user=ubuntu
newkey=new_key

# Check if the KEY_PATH variable is set
if [[ -z $KEY_PATH ]]; then
   echo "KEY_PATH variable not found"
   exit 5
fi

# Check if the private IP address is provided
if [[ -z $private_ip ]]; then
  echo "Please provide IP address"
  exit 5
fi

# Check if the new key file does not exist
if [[ ! -f ~/$newkey ]]; then
    # Generate a new SSH key pair
    ssh-keygen -f ~/$newkey -t rsa -N "" 1> /dev/null

    # Set proper permissions for the public key file
    chmod 600 ~/$newkey.pub

    # Copy the public key to the remote server's authorized_keys file
    scp -o StrictHostKeyChecking=no -i $KEY_PATH ~/$newkey.pub $user@$private_ip:~/.ssh/authorized_keys 1> /dev/null 2> /dev/null

# If the new key file already exists
elif [[ -f ~/$newkey ]]; then
    # Backup the existing key file
    mv ~/$newkey ~/$newkey.bak

    # Generate a new SSH key pair
    ssh-keygen -f ~/$newkey -t rsa -N "" 1> /dev/null

    # Copy the public key to the remote server's authorized_keys file
    scp -o StrictHostKeyChecking=no -i ~/$newkey.bak ~/$newkey.pub $user@$private_ip:~/.ssh/authorized_keys 1> /dev/null 2> /dev/null

    # Remove the backup file
    rm ~/$newkey.bak
fi
