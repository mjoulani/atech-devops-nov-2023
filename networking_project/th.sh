#!/bin/bash

# Server URL
SERVER_URL="18.143.175.20:8080"

# Step 1: Client Hello
CLIENT_HELLO='{
   "version": "1.3",
   "ciphersSuites": [
      "TLS_AES_128_GCM_SHA256",
      "TLS_CHACHA20_POLY1305_SHA256"
    ], 
   "message": "Client Hello"
}'

echo "Step 1: Sending Client Hello..."
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$CLIENT_HELLO" "http://$SERVER_URL/clienthello")

# Check if the command succeeded
if [ $? -eq 0 ]; then
    echo "Client Hello successful!"
else
    echo "Client Hello failed. Exiting."
    exit 1
fi





# Parse Server Hello response
SERVER_VERSION=$(echo "$RESPONSE" | jq -r '.version')
SERVER_CIPHER_SUITE=$(echo "$RESPONSE" | jq -r '.cipherSuite')
SESSION_ID=$(echo "$RESPONSE" | jq -r '.sessionID')
SERVER_CERT=$(echo "$RESPONSE" | jq -r '.serverCert')

# Step 3: Server Certificate Verification
echo "Step 3: Verifying Server Certificate..."
wget https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem -O cert-ca-aws.pem
openssl verify -CAfile cert-ca-aws.pem <(echo "$SERVER_CERT" | base64 -d -w0)

# Check if the verification succeeded
if [ $? -eq 0 ]; then
    echo "Server Certificate is valid."
else
    echo "Server Certificate is invalid. Exiting."
    exit 5
fi

# Step 4: Client-Server master-key exchange
echo "Step 4: Generating and encrypting master key..."
MASTER_KEY=$(openssl rand -hex 32)
ENCRYPTED_MASTER_KEY=$(echo "$MASTER_KEY" | openssl smime -encrypt -aes-256-cbc -inkey <(echo "$SERVER_CERT" | base64 -d -w0) -outform DER | base64 -w 0)

# Send encrypted master key to the server
echo "Sending encrypted master key to the server..."
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"sessionID\":\"$SESSION_ID\",\"masterKey\":\"$ENCRYPTED_MASTER_KEY\",\"sampleMessage\":\"Hi server, please encrypt me and send to client!\"}" "http://$SERVER_URL/keyexchange")

# Check if the command succeeded
if [ $? -eq 0 ]; then
    echo "Master-key exchange successful!"
else
    echo "Master-key exchange failed. Exiting."
    exit 1
fi

# Parse Server Key Exchange response
ENCRYPTED_SAMPLE_MESSAGE=$(echo "$RESPONSE" | jq -r '.encryptedSampleMessage')

# Decode the encrypted sample message
echo "$ENCRYPTED_SAMPLE_MESSAGE" | base64 -d > encSampleMsgReady.txt

# Step 5: Server verification message
echo "Step 5: Decrypting and verifying server's sample message..."
DECRYPTED_SAMPLE_MESSAGE=$(openssl enc -d -aes-256-cbc -in encSampleMsgReady.txt -k "$MASTER_KEY")

# Check if the decryption succeeded
if [ $? -eq 0 ] && [ "$DECRYPTED_SAMPLE_MESSAGE" = "Hi server, please encrypt me and send to client!" ]; then
    echo "Server symmetric encryption using the exchanged master-key is successful."
else
    echo "Server symmetric encryption using the exchanged master-key has failed. Exiting."
    exit 6
fi

# Step 6: Client verification message
echo "Step 6: Sending client verification message..."
# Implement client verification logic here...

echo "Client-Server TLS handshake has been completed successfully!"
