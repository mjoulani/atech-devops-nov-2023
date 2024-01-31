#!/bin/bash

# TODO Your solution here

client_hello_response=$(curl -X POST -H "Content-Type: application/json" -d '{
  "version": "1.3",
  "ciphersSuites": [
    "TLS_AES_128_GCM_SHA256",
    "TLS_CHACHA20_POLY1305_SHA256"
  ],
  "message": "Client Hello"
}' http://18.143.175.20:8080/clienthello)

if [ $? -ne 0 ]; then
  echo "Client Hello failed."
  exit 1
fi


server_version=$(echo "$client_hello_response" | jq -r '.version')
server_cipher_suite=$(echo "$client_hello_response" | jq -r '.cipherSuite')
session_id=$(echo "$client_hello_response" | jq -r '.sessionID')
server_cert=$(echo "$client_hello_response" | jq -r '.serverCert')

echo "$session_id" > session_id.txt
echo "$server_cert" > server_cert.pem


wget https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem -O cert-ca-aws.pem

openssl verify -CAfile cert-ca-aws.pem <<< "$server_cert"

if [ $? -ne 0 ]; then
  echo "Server Certificate is invalid."
  exit 5
fi


MASTER_KEY=$(openssl rand -base64 32)
encrypted_master_key=$(echo "$MASTER_KEY" | openssl smime -encrypt -aes-256-cbc -outform DER <(echo "$server_cert") | base64 -w 0)

key_exchange_payload='{
  "sessionID": "'"$session_id"'",
  "masterKey": "'"$encrypted_master_key"'",
  "sampleMessage": "Hi server, please encrypt me and send to client!"
}'

key_exchange_response=$(curl -s -X POST -H "Content-Type: application/json" -d "$key_exchange_payload" http://18.143.175.20:8080/keyexchange)

if [ -z "$key_exchange_response" ]; then
  echo "Key Exchange failed."
  exit 2
fi

echo "$key_exchange_response"
encrypted_sample_message=$(echo "$key_exchange_response" | jq -r '.encryptedSampleMessage')


echo "$encrypted_sample_message" | base64 -d > encSampleMsgReady.txt


decrypted_message=$(openssl enc -d -aes-256-cbc -pbkdf2 -in encSampleMsgReady.txt -pass pass:"$MASTER_KEY")

echo "$decrypted_message"

if [ "$decrypted_message" != "Hi server, please encrypt me and send to client!" ]; then
  echo "Server symmetric encryption using the exchanged master-key has failed."
  exit 6
fi

echo "Client-Server TLS handshake has been completed successfully"