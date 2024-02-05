#!/bin/bash

# KEY_PATH

# Check if KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
     echo "KEY_PATH env var is excpected."
     exit 5
fi

# Case 1 - connect to the private instance from your local machine 
if [ $# -eq 2 ]; then
    ssh -o "ProxyCommand ssh -W %h:%p -i $KEY_PATH ubuntu@$1 " ubuntu@$2
    exit $?
fi


# Case 2 - connect to the public instance
if [ $# -eq 1 ]; then
    ssh -i "$KEY_PATH" ubuntu@$1
    exit $?
fi


# Case 3 - run a command in the private machine
if [ $# -eq 3 ]; then
    ssh -o "ProxyCommand ssh -W %h:%p -i $KEY_PATH ubuntu@$1" ubuntu@$2 "$3"
    exit $?
fi

# Case 4 - bad usage
echo "Please provide bastion IP address"
exit 5
