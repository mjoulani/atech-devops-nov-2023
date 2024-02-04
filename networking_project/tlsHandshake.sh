#!/bin/bash


Pub_IP=$1

usage(){
    echo "tlsHandShake.sh [ip]"
}

failed(){
    echo "Server symmetric encryption using the exchanged master-key has failed."
    exit 6
}

success(){
    echo "Client-Server TLS handshake has been completed successfully"
    exit 0
}

check_if_server_is_working(){
    curl $Pub_IP:8080/status
    if [[ $? -ne 0 ]];then
        echo "server is not online"
        exit 1
    fi
}

send_hello(){
    curl -X POST -d '{
    "version": "1.3",
    "ciphersSuites": [
        "TLS_AES_128_GCM_SHA256",
        "TLS_CHACHA20_POLY1305_SHA256"
        ], 
    "message": "Client Hello"
    }' $Pub_IP:8080/clienthello -H 'Content-Type: application/json'
    }

    validateCert(){
    openssl verify -CAfile cert-ca-aws.pem cert.pem 2> /dev/null
    if [[ $? -ne 0 ]];then
        echo "Server Certificate is invalid."
        exit 5
    fi
}

randomKey(){
    openssl rand 32 | base64  > master_key
    }
    encryptMasterKey(){
    openssl smime -encrypt -aes-256-cbc -in master_key -outform DER cert.pem | base64 -w 0
}



send_key(){
    curl -X POST \
    -d '{
        "sessionID": "'$SESSION_ID'",
        "masterKey": "'$MASTER_KEY'",
        "sampleMessage": "Hi server, please encrypt me and send to client!"
    }' \
    $Pub_IP:8080/keyexchange -H 'Content-Type: application/json'
}

decrypt(){
    echo $response | jq -r .encryptedSampleMessage | base64 -d > encSampleMsgReady.txt
    openssl enc -d -aes-256-cbc -pbkdf2 -in encSampleMsgReady.txt -out decrypted.txt -pass file:master_key
}



main(){

if [[ -z $Pub_IP ]];then
    echo "please provide the server's ip: "
    usage
    exit 6
fi

check_if_server_is_working
echo "Beginning TLS with hello client .."
response=$(send_hello 2> /dev/null)
SESSION_ID=$(echo $response | jq -r .sessionID)
echo $response | jq -r .serverCert > cert.pem
echo "Validating Certificate ..."
validateCert
echo "Generating Master Key"
randomKey
echo "Encrypting master key with certificate"
MASTER_KEY=$(encryptMasterKey)
echo "Sending Key ..."
response=$(send_key 2> /dev/null)
echo "Decrypting message.."
decrypt
if [[ $(cat decrypted.txt) == "Hi server, please encrypt me and send to client!" ]];then
    cat decrypted.txt
    success
else
    failed
fi
}

main