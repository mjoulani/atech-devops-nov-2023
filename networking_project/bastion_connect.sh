#!/bin/bash
if [ -z "$KEY_PATH" ] || [ ! -f "$KEY_PATH" ]; then
  echo "Error"
  exit 5
fi
if [ $# -lt 1 ]; then
  echo "Error:provide bastion IP address."
  exit 5
fi
validate_ip() {
  local ip="$1"
  if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error."
    exit 5
  fi
}
BASTION_IP=$1
validate_ip "$BASTION_IP"
if [ $# -eq 2 ]; then
  PRIVATE_IP=$2
  validate_ip "$PRIVATE_IP"
  ssh -i "$KEY_PATH" -o "ProxyJump=$BASTION_IP" ubuntu@"$PRIVATE_IP"
else
  # Connect to the public instance
  ssh -i "$KEY_PATH" ubuntu@"$BASTION_IP"
fi
