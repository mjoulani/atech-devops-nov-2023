#!/bin/bash
export KEY_PATH=~/Desktop/DevOps/atech-devops-nov-2023/networking_project/ofer-bakria-key.pem
public_ins="$1"
private_ins="$2"

# if [ -z "${KEY_PATH}" ]; then
    # echo "VAR is unset or set to the empty string"
# else
    # echo "VAR is set to some string"
# fi

# ssh -t -i $KEY_PATH ubuntu@$public_ins ". connect.sh 10.0.1.94"
ssh -t -i $KEY_PATH ubuntu@$public_ins "ssh -i ofer-bakria-key02.pem ubuntu@10.0.1.94"



# echo "$public_ins"
# echo "$private_ins"

# echo "$KEY_PATH"
# echo "$?"
# TODO your solution here
# scp -i /path/to/private-key your-local-file.txt user@remote-server:/path/on/remote-server/
