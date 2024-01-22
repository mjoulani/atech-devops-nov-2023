#!/bin/bash
export KEY_PATH=~/Desktop/DevOps/atech-devops-nov-2023/networking_project/ofer-bakria-key.pem
public_ins="$1"
private_ins="$2"


if [ "$#" -eq 1 ]; then
    echo "1"
elif [ "$#" -eq 2 ]; then
    echo "2"
else
    echo "3"
fi

# if [ -z "${KEY_PATH}" ]; then
    # echo "VAR is unset or set to the empty string"
# else
    # echo "VAR is set to some string"
# fi

# ssh -t -i $KEY_PATH ubuntu@$public_ins ". connect.sh 10.0.1.94"
ssh -t -i $KEY_PATH ubuntu@$public_ins "ssh -i ofer-bakria-key02.pem ubuntu@10.0.1.94 'ls -la'"


# echo "$KEY_PATH"
# echo "$?"
# TODO your solution here
# scp -i /path/to/private-key your-local-file.txt user@remote-server:/path/on/remote-server/
