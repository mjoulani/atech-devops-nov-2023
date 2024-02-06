#!/bin/bash

# Public IP of the EC2 instance
public_ip=$1

# Step 1: Send Client Hello and receive Server Hello
echo "Sending Client Hello..."
SERVER_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{"version": "1.3", "ciphersSuites": ["TLS_AES_128_GCM_SHA256", "TLS_CHACHA20_POLY1305_SHA256"], "message": "Client Hello"}' http://"$public_ip":8080/clienthello)

# Check if curl command was successful
if [ $? -ne 0 ]; then
    echo "Failed to send Client Hello."
    exit 1
fi

# Parse Server Hello response
VERSION=$(echo $SERVER_RESPONSE | jq -r '.version')
CIPHER_SUITE=$(echo $SERVER_RESPONSE | jq -r '.cipherSuite')
SESSION_ID=$(echo $SERVER_RESPONSE | jq -r '.sessionID')
SERVER_CERT=$(echo $SERVER_RESPONSE | jq -r '.serverCert')

# Step 2: Verify Server Certificate
wget -q https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem
openssl verify -CAfile cert-ca-aws.pem <<< "$SERVER_CERT" &> /dev/null

# Check certificate verification result
if [ $? -ne 0 ]; then
    echo "Server Certificate is invalid."
    exit 5
fi

echo "Server Certificate is valid."

# Step 3: Generate Master Key
MASTER_KEY=$(openssl rand -base64 32)

# Step 4: Encrypt Master Key with Server Certificate
ENCRYPTED_MASTER_KEY=$(echo "$MASTER_KEY" | openssl smime -encrypt -aes-256-cbc -binary -outform DER <(echo "$SERVER_CERT") | base64 -w 0)

# Step 5: Send Encrypted Master Key to Server
echo "Sending encrypted Master Key to server..."
KEY_EXCHANGE_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{"sessionID": "'"$SESSION_ID"'", "masterKey": "'"$ENCRYPTED_MASTER_KEY"'", "sampleMessage": "Hi server, please encrypt me and send to client!"}' http://"$public_ip":8080/keyexchange)

# Check if curl command was successful
if [ $? -ne 0 ]; then
    echo "Failed to send encrypted Master Key."
    exit 1
fi

# Parse Key Exchange response
ENCRYPTED_SAMPLE_MESSAGE=$(echo $KEY_EXCHANGE_RESPONSE | jq -r '.encryptedSampleMessage')

# Step 6: Decrypt and Verify Sample Message
echo "$ENCRYPTED_SAMPLE_MESSAGE" | base64 -d > encSampleMsgReady.txt
DECRYPTED_MESSAGE=$(openssl enc -d -aes-256-cbc -in encSampleMsgReady.txt -k "$MASTER_KEY" 2>/dev/null)

# Check if decryption was successful
if [ $? -ne 0 ]; then
    echo "Server symmetric encryption using the exchanged master-key has failed."
    exit 6
fi

# Verify decrypted message
if [ "$DECRYPTED_MESSAGE" != "Hi server, please encrypt me and send to client!" ]; then
    echo "Decrypted message does not match the original message."
    exit 6
fi

echo "Client-Server TLS handshake has been completed successfully"
echo "Well Done! you’ve manually implemented a secure communication over HTTP! Thank god we have TLS in real life :-)"
