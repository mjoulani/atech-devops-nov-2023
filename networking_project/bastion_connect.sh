#!/bin/bash


if [[ -z "$KEY_PATH" ]]; then
  echo "KEY_PATH env var is not set"
  exit 5
fi

if [ $# -lt 1 ]; then
    echo "Please provide bastion IP address"
    exit 5
fi


BASTION_IP="$1"
PRIVATE_IP="${2:-}"
PRIVATE_KEY_PATH="$KEY_PATH"


if [[ $# -gt 1 ]]; then
  bastion_key_check=$(ssh -i "$KEY_PATH" ubuntu@$BASTION_IP "test -f new_key && echo 'exists' || echo 'not found'")
  if [[ "$bastion_key_check" == "exists" ]]; then
    PRIVATE_KEY_PATH="~/new_key"
    echo "Using new_key for private instance connection"
  fi
fi

ssh_command="ssh -i $KEY_PATH"

if [ $# -eq 1 ]; then

    ssh_command="$ssh_command ubuntu@$BASTION_IP"

fi

if [ $# -gt 1 ]; then

    ssh_command="$ssh_command -o ProxyCommand=\"ssh -W %h:%p -i \"$PRIVATE_KEY_PATH\" ubuntu@$BASTION_IP\" ubuntu@$PRIVATE_IP"

fi

if [[ $# -gt 2 ]]; then

  additional_commands="${@:3}"
  ssh_command="$ssh_command $additional_commands"

fi

eval "$ssh_command"