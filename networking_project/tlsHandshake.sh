#!/bin/bash

# Step 1: Client Hello HTTP Request
echo "Step 1: Sending Client Hello HTTP Request..."
client_hello_response=$(curl -s -X POST "http://${server_hostname}:${server_port}/clienthello" \
    -d '{"version": "1.3", "ciphersSuites": ["TLS_AES_128_GCM_SHA256", "TLS_CHACHA20_POLY1305_SHA256"], "message": "Client Hello"}')

# Check if the request was successful
if [ $? -ne 0 ]; then
    echo "Error sending Client Hello HTTP Request."
    exit 2
fi

# Parse Server Hello response using jq
version=$(echo "$client_hello_response" | jq -r '.version')
cipherSuite=$(echo "$client_hello_response" | jq -r '.cipherSuite')
sessionID=$(echo "$client_hello_response" | jq -r '.sessionID')
serverCert=$(echo "$client_hello_response" | jq -r '.serverCert')

echo "Received Server Hello response:"
echo "Version: $version"
echo "Cipher Suite: $cipherSuite"
echo "Session ID: $sessionID"
echo "Server Certificate: $serverCert"

# Step 2: Verify Server Certificate
echo "Step 2: Verifying Server Certificate..."
wget -O cert-ca-aws.pem "$ca_cert_url"
openssl verify -CAfile cert-ca-aws.pem "$serverCert"

# Check if certificate verification was successful
if [ $? -ne 0 ]; then
    echo "Server Certificate is invalid."
    exit 5
fi

echo "Server Certificate is valid."

# Step 3: Generate 32 random bytes base64 string as master-key
echo "Step 3: Generating 32 random bytes base64 string as master-key..."
masterKey=$(openssl rand -base64 32)

echo "Master Key: $masterKey"

# Step 4: Encrypt master-key with server certificate
echo "Step 4: Encrypting Master Key with Server Certificate..."
encryptedMasterKey=$(echo -n "$masterKey" | openssl smime -encrypt -aes-256-cbc -outform DER -recip "$serverCert" | base64 -w 0)

# Step 5: Perform key exchange with the server
echo "Step 5: Performing Key Exchange with Server..."
keyExchangeResponse=$(curl -s -X POST "http://${server_hostname}:${server_port}/keyexchange" \
    -d "{\"sessionID\": \"$sessionID\", \"masterKey\": \"$encryptedMasterKey\", \"sampleMessage\": \"Hi server, please encrypt me and send to client!\"}")

# Parse Key Exchange response using jq
encryptedSampleMessage=$(echo "$keyExchangeResponse" | jq -r '.encryptedSampleMessage')

# Step 6: Decrypt the sample message using the master-key
echo "Step 6: Decrypting Sample Message using Master Key..."
echo "$encryptedSampleMessage" | base64 -d > encSampleMsgReady.txt
decryptedSampleMessage=$(openssl enc -d -aes-256-cbc -in encSampleMsgReady.txt -base64 -K $(echo -n "$masterKey" | base64 -d) -iv 0)

# Check if decryption was successful
if [ $? -ne 0 ]; then
    echo "Step 6: Server symmetric encryption using the exchanged master-key has failed."
    exit 6
fi

echo "Step 6: Server symmetric encryption using the exchanged master-key successful."

# Additional steps (if needed) can be added here

echo "Client-Server TLS handshake has been completed successfully."
exit 0
