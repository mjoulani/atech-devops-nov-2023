#!/bin/bash

# Step 1: Client Hello
curl -X POST -H "Content-Type: application/json" -d '{"version": "1.3", "ciphersSuites": ["TLS_AES_128_GCM_SHA256", "TLS_CHACHA20_POLY1305_SHA256"], "message": "Client Hello"}' http://54.248.155.11:8080/clienthello > server_hello.json

if [[ $? -eq 0 ]]; then
  echo "Client Hello sent successfully."
else
  echo "Failed to send Client Hello."
  exit 1
fi

# Parse Server Hello response
SESSION_ID=$(jq -r '.sessionID' server_hello.json)
SERVER_CERT=$(jq -r '.serverCert' server_hello.json)
VERSION=$(jq -r '.version' server_hello.json)
CIPHER_SUITE=$(jq -r '.cipherSuite' server_hello.json)


# Step 2: Server Certificate Verification
echo "Verifying Server Certificate..."
wget -q https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem -O cert-ca-aws.pem

openssl verify -CAfile cert-ca-aws.pem <(echo "$SERVER_CERT")

# Check certificate verification result
if [[ $? -eq 0 ]]; then
  echo "Server certificate verified successfully."
else
  echo "Server Certificate is invalid."
  exit 5
fi

echo

# Step 3: Generate Master Key
MASTER_KEY=$(openssl rand -base64 32)

# Step 4: Encrypt Master Key
echo "Encrypting Master Key..."
ENCRYPTED_MASTER_KEY=$(echo "$MASTER_KEY" | openssl smime -encrypt -aes-256-cbc -outform DER <(echo "$SERVER_CERT") | base64 -w 0)

# Step 5: Send Encrypted Master Key to Server
echo "Sending Encrypted Master Key to Server..."

KEY_EXCHANGE='{"sessionID": "'$SESSION_ID'", "masterKey": "'$ENCRYPTED_MASTER_KEY'", "sampleMessage": "Hi server, please encrypt me and send to client!"}'

RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$KEY_EXCHANGE" http://54.248.155.11:8080/keyexchange)

# Check if Key Exchange was successful
if [ -z "$RESPONSE" ]; then
    echo "Error: Failed to perform key exchange."
    exit 1
fi

echo "Received Server Verification Response:"
echo "$RESPONSE"
echo

# Parse Server Verification response
ENCRYPTED_SAMPLE_MESSAGE=$(echo "$RESPONSE" | jq -r '.encryptedSampleMessage')

# Step 6: Decrypt and Verify Sample Message
echo "Decrypting and Verifying Sample Message..."
echo "$ENCRYPTED_SAMPLE_MESSAGE" | base64 -d > encSampleMsgReady.txt
DECRYPTED_SAMPLE_MESSAGE=$(openssl enc -d -aes-256-cbc -pbkdf2 -in encSampleMsgReady.txt -pass pass:"$MASTER_KEY")

# Check decryption result
if [ "$DECRYPTED_SAMPLE_MESSAGE" != "Hi server, please encrypt me and send to client!" ]; then
    echo "Error: Server symmetric encryption using the exchanged master-key has failed."
    exit 6
fi

echo "Client-Server TLS handshake has been completed successfully."
