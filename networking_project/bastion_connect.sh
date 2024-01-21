#!/bin/bash
public_ins="$1"
private_ins="$2"
ssh -i $KEY_PATH ubuntu@$public_ins "sudo ssh -i ofer-bakria-key02.pem ubuntu@$private_ins"


# echo "$public_ins"
# echo "$private_ins"

ssh -i $KEY_PATH ubuntu@$public_ins

# echo "$KEY_PATH"
# echo "$?"
# TODO your solution here
# scp -i /path/to/private-key your-local-file.txt user@remote-server:/path/on/remote-server/
