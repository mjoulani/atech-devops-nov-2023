#!/bin/bash

export KEY_PATH=~/key.pem
#Check if KET_PATH variable is set
if [ -z "$KEY_PATH" ]; then
  echo "KEY_PATH env var is expected"
  exit 5
fi

#Check if the private ip send
if [ "$#" -lt 1 ]; then
  echo "Please provide IP address"
  exit 5
fi

private_instance_ip="$1"

if [[ -f new_key ]];then
 mv new_key new_old_key
 export KEY_PATH=new_old_key
fi

# Generate new SSH key pair
echo "Generating new SSH key pair..."
ssh-keygen -t rsa -b 2048 -f ~/new_key -N ""

#Give the key a permission of read and write
chmod 600 ~/new_key.pub

#copy the new_key.pub file inside the private instance
scp -i "$KEY_PATH" ./new_key.pub "ubuntu@$private_instance_ip":~
# Adding the new_key.pub to the authorized keys of private instance
ssh -i "$KEY_PATH" "ubuntu@$private_instance_ip" "cp -f ~/new_key.pub ~/.ssh/authorized_keys"
