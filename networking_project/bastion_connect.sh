#!/bin/bash

# Check if KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
  echo "KEY_PATH env var is expected"
  exit 5
fi

ssh-add "$KEY_PATH"

if [ "$#" -lt 1 ]; then
  echo "Please provide bastion IP address"
  exit 5
fi

public_instance_ip="$1"
private_instance_ip="$2"

scp -q -i "$KEY_PATH" ssh_keys_rotation.sh ubuntu@"$public_instance_ip":ssh_keys_rotation.sh

switch(){
ssh -q -i "$KEY_PATH" ubuntu@"$public_instance_ip" -t "bash -s" <<EOF
#!/bin/bash
if [[ -f new_key ]];then
 export KEY_PATH=new_key; bash ssh_keys_rotation.sh $private_instance_ip
else
  export KEY_PATH=key.pem; bash ssh_keys_rotation.sh $private_instance_ip
fi
EOF
}

if [ -z "$private_instance_ip" ]; then
  ssh -i "$KEY_PATH" ubuntu@"$public_instance_ip"
  echo "Successfully connect to the public instance"
else
  switch
  scp -q -i "$KEY_PATH" ubuntu@"$public_instance_ip":new_key .
  ssh-add new_key
  ssh -A -i "$KEY_PATH" -J ubuntu@"$public_instance_ip" ubuntu@"$private_instance_ip" "${@:3}"
  echo "Successfully connect to the private instance"
fi
