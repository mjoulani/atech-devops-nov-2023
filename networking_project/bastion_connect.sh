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

checkKey=$(ssh -q -o StrictHostKeyChecking=no -i ${KEY_PATH} ${User}@${PubIP} -t 'ls Fnaarani.pem 2> /dev/null | wc -l')
echo $checkKey
if [[ "$checkKey" != "1" ]];then
    scp -q -o StrictHostKeyChecking=no -i ${KEY_PATH} $KEY_PATH ubuntu@${PubIP}:~
    echo "COPIED KEY TO $PubIP"
    ssh -q -o StrictHostKeyChecking=no -i ${KEY_PATH} ${User}@${PubIP} -t "chmod 600 $KEY_PATH"
    echo "ADDED PERMISTIONS"
fi

ssh -q -o StrictHostKeyChecking=no -i ${KEY_PATH} ${User}@${PubIP} -t "bash -s" <<EOF
#!/bin/bash
grep Fnaarani.pem .bashrc 1> /dev/null
if [[ "\$?" != "0" ]];then
sed -i '1s/^/export KEY_PATH=Fnaarani.pem\\n/' .bashrc
fi
EOF

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