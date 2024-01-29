#!/bin/bash

echo "1****************************"

client_hello_response=$(curl -X POST -H "Content-Type: application/json" -d '{
  "version": "1.3",
  "ciphersSuites": [
    "TLS_AES_128_GCM_SHA256",
    "TLS_CHACHA20_POLY1305_SHA256"
  ],
  "message": "Client Hello"
}' http://0.0.0.0:8080/clienthello)

if [ $? -ne 0 ]; then
  echo "Client Hello failed."
  exit 1
fi

echo "2****************************"

server_version=$(echo "$client_hello_response" | jq -r '.version')
server_cipher_suite=$(echo "$client_hello_response" | jq -r '.cipherSuite')
session_id=$(echo "$client_hello_response" | jq -r '.sessionID')
server_cert=$(echo "$client_hello_response" | jq -r '.serverCert')

echo "$session_id" > session_id.txt
echo "$server_cert" > server_cert.pem

echo "3****************************"

ca_cert_url="https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem"
wget -O cert-ca-aws.pem "$ca_cert_url"

openssl verify -CAfile cert-ca-aws.pem server_cert.pem

if [ $? -ne 0 ]; then
  echo "Server Certificate is invalid."
  exit 5
fi

echo "4**************************** start from here need fixing "

master_key=$(openssl rand -hex 32)

encrypted_master_key=$(echo "$master_key" | openssl smime -encrypt -aes-256-cbc -outform DER -recip server_cert.pem | base64 -w 0)

key_exchange_payload='{
  "sessionID": "'"$session_id"'",
  "encryptedMasterKey": "'"$encrypted_master_key"'",
  "sampleMessage": "Hi server, please encrypt me and send to client!"
}'

key_exchange_response=$(curl -X POST -H "Content-Type: application/json" -d "$key_exchange_payload" http://0.0.0.0:8080/keyexchange)

if [ $? -ne 0 ]; then
  echo "Key Exchange failed."
  exit 2
fi

session_id=$(echo "$key_exchange_response" | jq -r '.sessionID')
encrypted_sample_message=$(echo "$key_exchange_response" | jq -r '.encryptedSampleMessage')


