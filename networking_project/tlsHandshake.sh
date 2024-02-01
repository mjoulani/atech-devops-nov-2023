#!/bin/bash
set -e

echo "sending cilentHello "
SERVER_HELLO_RES=$(curl -s -S -X POST $1:8080/clienthello -H "Content-Type: application/json" \
-d '{
     "version": "1.3",
   "ciphersSuites": [
      "TLS_AES_128_GCM_SHA256",
      "TLS_CHACHA20_POLY1305_SHA256"
    ], 
   "message": "Client Hello"
}' \
) 
echo "receiving server hello "
echo $SERVER_HELLO_RES | jq  -r '.serverCert' > cert.pem
SESSION_ID=$(echo $SERVER_HELLO_RES | jq  -r '.sessionID') 

wget -q https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem

echo "verify cert "
VER_ANS=$(openssl verify -CAfile cert-ca-aws.pem cert.pem)
if [[ $VER_ANS != "cert.pem: OK"  ]]; then
  exit 5
fi;


echo "create random  master key"
openssl rand -base64 32 > master-key.txt
echo "encrpted the master key with public server key"
MASTER_KEY_ENC=$(openssl smime -encrypt -aes-256-cbc -in master-key.txt -outform DER cert.pem | base64 -w 0) 
MSG_TO_TEST="Hello"
res=$(curl -s -S -X POST $1:8080/keyexchange -H "Content-Type: application/json" \
-d '{
      "sessionID": "'$SESSION_ID'",
      "masterKey": "'$MASTER_KEY_ENC'",
      "sampleMessage": "'$MSG_TO_TEST'"
}' \
) 

MSG_FROM_SERVER=$(echo $res| jq -r '.encryptedSampleMessage') 
echo $MSG_FROM_SERVER | base64 -d  > encSampleMsgReady.txt
openssl enc -d -aes-256-cbc --pbkdf2 -in  encSampleMsgReady.txt -out decrypted_message.txt -pass file:./master-key.txt
MSG_FROM_SERVER=$(cat decrypted_message.txt)
if [[ $MSG_FROM_SERVER == $MSG_TO_TEST ]]; then
  echo "Client-Server TLS handshake has been completed successfully"
else 
  echo "Server symmetric encryption using the exchanged master-key has failed."  
  exit 6
fi;

