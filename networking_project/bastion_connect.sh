#!/bin/bash
set -e
if [ -z "${KEY_PATH}" ]; then
  echo "KEY_PATH env var is expected"
  exit 5  
fi

if [ -n "${3}"  ]; then
    echo "please wait the operation may take  few seconds"
    ssh -t -i  $KEY_PATH  "ubuntu@"$1   ssh -i /home/ubuntu/abed-private-ec2.pem "ubuntu@"$2 "$3"
    exit 
fi

if [[  -n $2  ]]; then
    echo "please wait the operation may take  few seconds"
    ssh -t -i  $KEY_PATH  "ubuntu@"$1   ssh -i /home/ubuntu/abed-private-ec2.pem "ubuntu@"$2
    exit
fi

if [[  -n $1  ]]; then
    echo "please wait the operation may take  few seconds"
    ssh -i $KEY_PATH  "ubuntu@"$1  
    exit
else 
    echo "Please provide bastion IP address"
    exit 5
fi
