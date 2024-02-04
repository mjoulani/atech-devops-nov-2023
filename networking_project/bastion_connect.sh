                                                                                     bastion_connect.sh
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

switch(){
ssh -q -i "$KEY_PATH" ubuntu@"$public_instance_ip" -t "bash -s" <<EOF

if [[ -f new_key ]];then
 export KEY_PATH=new_key
else
 export KEY_PATH=key.pem
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


# TODO your solution here