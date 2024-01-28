#!/bin/bash

# Step 1 - Client Hello
CLIENT_HELLO_RESPONSE=$(curl -s -X POST "http://35.78.94.169:8080/clienthello" \
    -H "Content-Type: application/json" \
    -d '{"version": "1.3", "ciphersSuites": ["TLS_AES_128_GCM_SHA256", "TLS_CHACHA20_POLY1305_SHA256"], "message": "Client Hello"}')

# Parse the Server Hello response
SERVER_VERSION=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.version')
SERVER_CIPHER_SUITE=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.cipherSuite')
SESSION_ID=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.sessionID')
SERVER_CERT=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.serverCert')

# Step 2 - Server Hello
if [ -z "$SERVER_VERSION" ] || [ -z "$SERVER_CIPHER_SUITE" ] || [ -z "$SESSION_ID" ] || [ -z "$SERVER_CERT" ]; then
    echo "Error: Failed to get valid Server Hello response."
    exit 2
fi

# Step 3 - Server Certificate Verification
wget https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem -O cert-ca-aws.pem
openssl verify -CAfile cert-ca-aws.pem <<< "$SERVER_CERT"
if [ $? -ne 0 ]; then
    echo "Error: Server Certificate is invalid."
    exit 5
fi

# Step 4 - Client-Server Master-Key Exchange
MASTER_KEY=$(openssl rand -base64 32)
ENCRYPTED_MASTER_KEY=$(echo "$MASTER_KEY" | openssl smime -encrypt -aes-256-cbc -outform DER <(echo "$SERVER_CERT") | base64 -w 0)

# Step 5 key exchange
KEY_EXCHANGE='{"sessionID": "'$SESSION_ID'", "masterKey": "'$ENCRYPTED_MASTER_KEY'", "sampleMessage": "Hi server, please encrypt me and send to client!"}'
#Send the encripted master key
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$KEY_EXCHANGE" http://35.78.94.169:8080/keyexchange)
#check if the key exchange pass
if [ -z "$RESPONSE" ]; then
    echo "Error: Failed to perform key exchange."
    exit 1
fi
# Parse the ecripted massage
ENCRYPTED_SAMPLE_MESSAGE=$(echo "$RESPONSE" | jq -r '.encryptedSampleMessage')

# Decode the encrypted message before decryption
echo "$ENCRYPTED_SAMPLE_MESSAGE" | base64 -d > encSampleMsgReady.txt

# Decrypt the sample message and verify
DECRYPTED_SAMPLE_MESSAGE=$(openssl enc -d -aes-256-cbc -pbkdf2 -in encSampleMsgReady.txt -pass pass:"$MASTER_KEY")

#Step 6 clinet verify massage

if [ "$DECRYPTED_SAMPLE_MESSAGE" != "Hi server, please encrypt me and send to client!" ]; then
    echo "Error: Server symmetric encryption using the exchanged master-key has failed."
    exit 6
fi

# If everything is ok, print a positive message
echo "Client-Server TLS handshake has been completed successfully"

# TODO Your solution here