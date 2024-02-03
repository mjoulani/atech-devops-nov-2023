#!/bin/bash

# step 1: client Hello HTTP request
echo "Step 1: Sending Client Hello HTTP request..."
CLIENT_HELLO_RESPONSE=$(curl -s -X POST "http://35.78.94.169:8080/clienthello" \
    -h "Content-Type: application/json" \
    -d '{"VERSION": "1.3", "CIPHERS_SUITES": ["TLS_AES_128_GCM_SHA256", "TLS_CHACHA20_POLY1305_SHA256"], "MESSAGE": "Client Hello"}')

# check if the request was successful
if [ $? -ne 0 ]; then
    echo "Error sending Client Hello HTTP request."
    exit 2
fi

# parse server Hello response using jq
VERSION=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.VERSION')
CIPHER_SUITE=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.CIPHER_SUITE')
SESSION_ID=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.SESSION_ID')
SERVER_CERT=$(echo "$CLIENT_HELLO_RESPONSE" | jq -r '.SERVER_CERT')

echo "Received Server Hello response:"
echo "Version: $version"
echo "Cipher Suite: $cipherSuite"
echo "Session ID: $sessionID"
echo "Server Certificate: $serverCert"

# step 2: verify server certificate
echo "Step 2: Verifying server certificate..."
wget https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem -O cert-ca-aws.pem
openssl verify -CAfile cert-ca-aws.pem <<< "$SERVER_CERT"

# check if certificate verification was successful
if [ $? -ne 0 ]; then
    echo "Server certificate is invalid."
    exit 5
fi

echo "Server certificate is valid."

# step 3: Generate 32 random bytes base64 string as master-key
echo "Step 3: Generating 32 random bytes base64 string as master-key..."
masterKey=$(openssl rand -base64 32)

echo "Master Key: $masterKey"

# step 4: Encrypt master-key with server certificate
echo "Step 4: Encrypting master key with server certificate..."
encrypted_masterKey=$(echo -n "$masterKey" | openssl smime -encrypt -aes-256-cbc -outform DER -recip "$SERVER_CERT" | base64 -w 0)

# step 5: Perform key exchange with the server
echo "Step 5: Performing key exchange with Server..."
key_exchange_response=$(curl -s -X POST "http://${server_hostname}:${server_port}/keyexchange" \
    -d "{\"SESSION_ID\": \"$SESSION_ID\", \"masterKey\": \"$encrypted_masterKey\", \"sample_message\": \"Hi server, please encrypt me and send to the client!\"}")
#send the encripted master key
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$KEY_EXCHANGE" http://35.78.94.169:8080/keyexchange)
#check if the key exchange pass
if [ -z "$RESPONSE" ]; then
    echo "Error: Failed to perform key exchange."
    exit 1
fi

# parse key exchange response using jq
encrypted_sample_message=$(echo "$key_exchange_response" | jq -r '.encrypted_sample_message')

# step 6: Decrypt the sample message using the master-key
echo "Step 6: Decrypting sample message using master key..."
echo "$encrypted_sample_message" | base64 -d > enc_sample_msg_ready.txt
decrypted_sample_message=$(openssl enc -d -aes-256-cbc -in enc_sample_msg_ready.txt -base64 -K $(echo -n "$masterKey" | base64 -d) -iv 0)

# check if decryption was successful
if [ $? -ne 0 ]; then
    echo "Step 6: Server symmetric encryption using the exchanged master-key has failed."
    exit 6
fi

echo "Step 6: Server symmetric encryption using the exchanged master-key successful."

# final

echo "Client-Server TLS handshake has been completed successfully."
exit 0
