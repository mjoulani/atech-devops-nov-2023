
#!/bin/bash

# Check if KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH environment variable is expected"
    exit 5
fi

# Check the number of arguments
if [ "$#" -eq 0 ]; then
    echo "Please provide bastion IP address"
    exit 5
fi


PUBLIC_INSTANCE_IP=$1
PRIVATE_INSTANCE_IP=$2

# Check if a command is provided
if [ "$#" -gt 2 ]; then
    COMMAND="${@:3}"
else
    COMMAND=""
fi

# Connect to the public instance
if [ -n "$PRIVATE_INSTANCE_IP" ]; then
    if [ -n "$COMMAND" ]; then
        # Run a command on the private instance
        ssh -t -i "$KEY_PATH" ubuntu@"$PUBLIC_INSTANCE_IP" ssh -i "/home/ubuntu/SAbaa-key.pem" ubuntu@"$PRIVATE_INSTANCE_IP" "$COMMAND"
    else
        # Connect to the private instance using the public instance as a bastion host
        ssh -t -i "$KEY_PATH" ubuntu@"$PUBLIC_INSTANCE_IP" ssh -i"/home/ubuntu/SAbaa-key.pem"  ubuntu@"$PRIVATE_INSTANCE_IP"
    fi
else
    # Connect only to the public instance
    ssh -i "$KEY_PATH" ubuntu@"$PUBLIC_INSTANCE_IP"
fi