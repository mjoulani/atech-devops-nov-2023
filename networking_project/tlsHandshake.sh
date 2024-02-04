#!/bin/bash


# Step 1: Client Hello
CLIENT_HELLO_RESPONSE=$(curl -s -X POST http://52.14.216.174:8080/clienthello -d '{
   "version": "1.3",
   "ciphersSuites": [
      "TLS_AES_128_GCM_SHA256",
      "TLS_CHACHA20_POLY1305_SHA256"
    ],
   "message": "Client Hello"
}')

# Extract data from Server Hello response
SERVER_VERSION=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.version')
SERVER_CIPHER_SUITE=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.cipherSuite')
SESSION_ID=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.sessionID')
SERVER_CERT=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.serverCert')

# Step 2: Server Certificate Verification
wget https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem -O cert-ca-aws.pem
if ! openssl verify -CAfile cert-ca-aws.pem <<< "$SERVER_CERT" >/dev/null; then
    echo "Error: Server Certificate is invalid."
    exit 5
fi

# Step 3: Client-Server Master-Key Exchange
MASTER_KEY=$(openssl rand -base64 32)
ENCRYPTED_MASTER_KEY=$(openssl smime -encrypt -aes-256-cbc -in <(echo -n "$MASTER_KEY") -outform DER <(echo "$SERVER_CERT") | base64 -w 0)

# Step 4: Server Verification Message
KEY_EXCHANGE='{"sessionID": "'$SESSION_ID'", "masterKey": "'$ENCRYPTED_MASTER_KEY'", "sampleMessage": "Hi server, please encrypt me and send to client!"}'
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$KEY_EXCHANGE" http://52.14.216.174:8080/keyexchange)
if [ -z "$RESPONSE" ]; then
    echo "Error: Failed to perform key exchange."
    exit 1
fi

# Extract the encrypted sample message
ENCRYPTED_SAMPLE_MESSAGE=$(echo "$RESPONSE" | jq -r '.encryptedSampleMessage')

# Decode the encrypted message before decryption
echo -n "$ENCRYPTED_SAMPLE_MESSAGE" | base64 -d > encSampleMsgReady.txt

# Step 5: Client Verification Message
DECRYPTED_SAMPLE_MESSAGE=$(openssl enc -d -aes-256-cbc -pbkdf2 -in encSampleMsgReady.txt -pass pass:"$MASTER_KEY")

# Check if decryption is successful
if [ "$DECRYPTED_SAMPLE_MESSAGE" != "Hi server, please encrypt me and send to client!" ]; then
    echo "Error: Server symmetric encryption using the exchanged master-key has failed."
    exit 6
fi

# If everything is ok, print a positive message
echo "Client-Server TLS handshake has been completed successfully"

# TODO Your solution here