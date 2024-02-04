#!/bin/bash

# Step 1 - Client Hello
client_hello_response=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"version": "1.3", "ciphersSuites": ["TLS_AES_128_GCM_SHA256", "TLS_CHACHA20_POLY1305_SHA256"], "message": "Client Hello"}' \
  http://65.1.133.40/clienthello)

echo $client_hello_response > client_response

# Check if the response is valid JSON
if ! jq '.' <<< "${client_hello_response}" &> /dev/null; then
  echo "Invalid response from server. Exiting."
  exit 1
fi
echo "Response is valid"

# Parse Client Hello response
#version=$(jq -r '.version' <<< "${client_hello_response}")
#cipher_suite=$(jq -r '.cipherSuite' <<< "${client_hello_response}")
session_id=$(jq -r '.sessionID' <<< "${client_hello_response}")
server_cert=$(jq -r '.serverCert' <<< "${client_hello_response}")

echo $server_cert > cert.pem

# Step 2 - Server Certificate Verification
if ! openssl verify -CAfile cert-ca-aws.pem <<< "${server_cert}" &> /dev/null; then
#if ! openssl verify -CAfile cert-ca-aws.pem cert.pem &> /dev/null; then
  echo "Server Certificate is invalid. Exiting."
  exit 5
fi

echo "cert.pem: OK"

# Step 3 - Generate 32 random bytes base64 string as the master-key
generated_key=$(openssl rand -base64 32)

# Step 4 - Encrypt the master-key with the server certificate
master_key=$(echo "${generated_key}" | openssl smime -encrypt -aes-256-cbc \
  -outform DER <(echo "${server_cert}" | base64 -d) | base64 -w 0)

#master_key=$(echo "${generated_key}" | openssl smime -encrypt -aes-256-cbc \
 # -outform DER cert.pem | base64 -d) | base64 -w 0)  

# Step 5 - Client-Server master-key exchange
key_exchange_response=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"sessionID": "'"${session_id}"'", "masterKey": "'"${master_key}"'", "sampleMessage": "Hi server, please encrypt me and send to client!"}' \
  http://<public-ec2-instance-ip>:8080/keyexchange)

# Parse Key Exchange response
session_id_response=$(jq -r '.sessionID' <<< "${key_exchange_response}")
encrypted_sample_message=$(jq -r '.encryptedSampleMessage' <<< "${key_exchange_response}")

# Decode the encrypted sample message
echo "${encrypted_sample_message}" | base64 -d > encSampleMsgReady.txt

# Decrypt the sample message using the master-key
decrypted_sample_message=$(openssl enc -d -aes-256-cbc -in encSampleMsgReady.txt -K $(echo "${generated_key}" | base64 -d) -iv 0)

# Step 6 - Client verification message
if [ "${decrypted_sample_message}" != "Hi server, please encrypt me and send to client!" ]; then
  echo "Server symmetric encryption using the exchanged master-key has failed. Exiting."
  exit 6
fi

# If everything is ok, print a positive message
echo "Client-Server TLS handshake has been completed successfully"
