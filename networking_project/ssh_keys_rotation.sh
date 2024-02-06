#!/bin/bash

# Script to set up SSH key authentication for a remote server
# Usage: ./script_name.sh <private_ip>

private_ip=$1  # Assigning the first argument passed to the variable private_ip
user=ubuntu    # Setting the remote user as ubuntu
newkey=new_key # Naming the new SSH key file

# Checking if KEY_PATH environment variable is set
if [[ -z $KEY_PATH ]]; then
   echo "KEY_PATH variable not found"  # Displaying an error message if KEY_PATH is not set
   exit 5  # Exiting the script with exit code 5
fi

# Checking if private_ip variable is empty
if [[ -z $private_ip ]]; then
  echo "Please provide IP address"  # Prompting the user to provide IP address if private_ip is empty
  exit 5  # Exiting the script with exit code 5
fi

# Checking if new_key file already exists
if [[ -f ~/new_key ]]; then
    # If new_key exists, updating the SSH key path in .bashrc file and generating a new key pair
    sed -i 's/export KEY.*/export KEY_PATH=\~\/new_key/g' .bashrc  # Updating the KEY_PATH in .bashrc
    ssh-keygen -f ~/new1_key -N "" 1> /dev/null  # Generating a new SSH key pair
    scp -i $KEY_PATH  ~/new1_key.pub $user@$private_ip:~/.ssh/authorized_keys  # Copying the public key to remote server
    rm new_key new_key.pub  # Removing old key files
    mv new1_key new_key ; mv new1_key.pub new_key.pub  # Renaming the new key files
fi

# If new_key doesn't exist, generating a new SSH key pair
if [[ ! -f ~/new_key ]]; then
    ssh-keygen -f ~/new_key -N "" 1> /dev/null  # Generating a new SSH key pair
    scp -i $KEY_PATH  ~/new_key.pub $user@$private_ip:~/.ssh/authorized_keys  # Copying the public key to remote server
fi
