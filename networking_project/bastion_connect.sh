#!/bin/bash
set -e

# TODO your solution here


user="ubuntu"
public_ip=$1
private_ip=$2
CMD="$3"


if [[ -z "$KEY_PATH" ]];then
   echo "KEY_PATH env var is expected"
   exit 5
fi

chmod 600 "$KEY_PATH"

if [[ -z "$public_ip" ]];then
   echo "Please provide bastion IP address"
   exit 5
fi

scp -q -o StrictHostKeyChecking=no -i "$KEY_PATH" "$KEY_PATH" ./ssh_keys_rotation.sh ./update_KEY_PATH.sh "$user"@"$public_ip":'~/'
ssh -q -o StrictHostKeyChecking=no -i"$KEY_PATH" "$user"@"$public_ip" -t 'bash update_KEY_PATH.sh'
if [[ -z $private_ip ]];then
ssh -q -o StrictHostKeyChecking=no -i "$KEY_PATH" "$user"@"$public_ip"
elif [[ -n $private_ip ]] && [[ -z $CMD ]];then
ssh -q -o StrictHostKeyChecking=no -i "$KEY_PATH" "$user"@"$public_ip" -t "ssh -o StrictHostKeyChecking=no "$user"@"$private_ip" -i \$(echo \$KEY_PATH)"
elif [[ -n $CMD ]];then
ssh -q -o StrictHostKeyChecking=no -i "$KEY_PATH" "$user"@"$public_ip" -t "ssh -q -o StrictHostKeyChecking=no -i \$(echo \$KEY_PATH) "$user"@"$private_ip" -t "$CMD""
fi
