#!/bin/bash
PubIP=$1
PrvIP=$2
cmd=$3
User=ubuntu

#CheckCase1
if [[ -z $KEY_PATH ]];then
    echo "KEY_PATH env var is expected"
    exit 5
fi

#CheckCase2
if [[ -z $PubIP ]];then
    echo "Please provide bastion IP address"
    exit 5
fi

chmod 600  ${KEY_PATH}

case $# in
    1)
        ssh -q -o StrictHostKeyChecking=no -i ${KEY_PATH} ${User}@${PubIP}
        ;;
    2)
        ssh -q -o StrictHostKeyChecking=no -i ${KEY_PATH} ${User}@${PubIP} -t "ssh -q -o StrictHostKeyChecking=no -i \${KEY_PATH} ${User}@${PrvIP} -t"
        ;;
    3)
        ssh -q -o StrictHostKeyChecking=no -i ${KEY_PATH} ${User}@${PubIP} -t "ssh -q -o StrictHostKeyChecking=no -i \${KEY_PATH} ${User}@${PrvIP} -t $cmd"
        ;;
    *)
        echo "More than three parameters passed."
        exit
        ;;
esac