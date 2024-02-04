#!/bin/bash

# Check for required KEY_PATH environment variable
if [[ -z "$KEY_PATH" ]]; then
  echo "KEY_PATH env var is expected"
  exit 5
fi


# Check for correct number of arguments
if [ $# -lt 1 ]; then
    echo "Please provide bastion IP address"
    exit 5
fi


# Set bastion IP and optional private instance IP
BASTION_IP="$1"
PRIVATE_IP="${2:-}"
PRIVATE_KEY_PATH="$KEY_PATH"


# If two arguments are provided, check for new_key at the bastion
if [[ $# -gt 1 ]]; then
  bastion_key_check=$(ssh -i "$KEY_PATH" ubuntu@$BASTION_IP "test -f new_key && echo 'exists' || echo 'not found'")
  if [[ "$bastion_key_check" == "exists" ]]; then
    PRIVATE_KEY_PATH="~/new_key"
    echo "Using new_key for private instance connection"
  fi
fi


# Construct the SSH command
ssh_command="ssh -i $KEY_PATH"


# If only one argument is provided, connect to public instance
if [ $# -eq 1 ]; then
    
    ssh_command="$ssh_command ubuntu@$BASTION_IP"
    
fi

# If two arguments are provided, connect to private instance via bastion
if [ $# -gt 1 ]; then

    ssh_command="$ssh_command -o ProxyCommand=\"ssh -W %h:%p -i \"$PRIVATE_KEY_PATH\" ubuntu@$BASTION_IP\" ubuntu@$PRIVATE_IP"
    
fi

# Execute the SSH command with any additional arguments
if [[ $# -gt 2 ]]; then

  additional_commands="${@:3}"
  ssh_command="$ssh_command $additional_commands"
  
fi


# Execute the constructed SSH command
eval "$ssh_command"

