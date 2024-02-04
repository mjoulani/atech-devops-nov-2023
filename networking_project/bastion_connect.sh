#!/bin/bash
PubIP=$1
PrvIP=$2
cmd=$3
User=ubuntu
KeyRot=ssh_keys_rotation.sh

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


ssh -q -o StrictHostKeyChecking=no -i ${KEY_PATH} ${User}@${PubIP} -t "bash -s" <<EOF
#!/bin/bash
grep 'export KEY' .bashrc 1> /dev/null
if [[ "\$?" != "0" ]];then
sed -i '1s/^/export KEY_PATH="$(basename $KEY_PATH)"\\n/' .bashrc
fi
EOF

#Check if 'Key_Rotaion' Exists
c=$(ssh -q -o StrictHostKeyChecking=no -i ${KEY_PATH} ${User}@${PubIP} -t 'ls ssh_keys_rotation.sh 2> /dev/null | wc -l')
c=$(echo $c | tr -d '\r')
if [[ $c != 1 ]];then
    scp -q -o StrictHostKeyChecking=no -i ${KEY_PATH} $KeyRot ubuntu@${PubIP}:~
    echo "COPIED KEY ROTATION SCRIPT TO $PubIP"
    ssh -q -o StrictHostKeyChecking=no -i ${KEY_PATH} ${User}@${PubIP} -t "chmod +x $KeyRot"
    echo -e "ADDED PERMISTIONS\n####################"
fi

#Check if 'KEY_PATH' Exists
cpath=$(ssh -q -o StrictHostKeyChecking=no -i ${KEY_PATH} ${User}@${PubIP} -t 'ls "$KEY_PATH" 2> /dev/null | wc -l')
cpath=$(echo $cpath | tr -d '\r')
if [[ $cpath != 1 ]];then
    scp -q -o StrictHostKeyChecking=no -i ${KEY_PATH} $KEY_PATH ubuntu@${PubIP}:~
    echo "COPIED KEY TO $PubIP"
    ssh -q -o StrictHostKeyChecking=no -i ${KEY_PATH} ${User}@${PubIP} -t "chmod 600 \$KEY_PATH"
    echo -e "ADDED PERMISTIONS\n####################"
fi



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
