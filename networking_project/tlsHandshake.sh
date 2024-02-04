#!/bin/bash

# Function to handle errors
handle_error() {
  echo "Error: $1"
  exit $2
}

# Trap to clean up temporary files on exit or interruption
trap 'rm -f master_key.txt encSampleMsgReady.txt' EXIT

# Step 1 - Client Hello
client_hello_response=$(curl -X POST http://47.128.239.41:8080/clienthello -H "Content-Type: application/json" -d '{
  "version": "1.3",
  "ciphersSuites": [
    "TLS_AES_128_GCM_SHA256",
    "TLS_CHACHA20_POLY1305_SHA256"
  ],
  "message": "Client Hello"
}') || handle_error "Unable to send Client Hello." 1

# Parse the Client Hello response using jq
version=$(echo "$client_hello_response" | jq -r '.version')
cipher_suite=$(echo "$client_hello_response" | jq -r '.cipherSuite')  # Corrected variable name
session_id=$(echo "$client_hello_response" | jq -r '.sessionID')
server_cert=$(echo "$client_hello_response" | jq -r '.serverCert')

echo "Parsed values: version=$version, cipher_suite=$cipher_suite, session_id=$session_id, server_cert=$server_cert"

# Step 3 - Server Certificate Verification
wget https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem || handle_error "Failed to download CA file." 2

# Concatenate the server's certificate with the CA file
echo -e "$server_cert" >> cert-ca-aws.pem
openssl verify -CAfile cert-ca-aws.pem -no-CAfile <<< "$server_cert" || handle_error "Server certificate verification failed." 2
echo "Server Certificate is valid."

# Step 4 - Client-Server master-key exchange
master_key=$(openssl rand -base64 32) || handle_error "Failed to generate master key." 3
echo "Master Key: $master_key"
echo -n "$master_key" > master_key.txt

# Encrypt the master key using S/MIME (PKCS#7) envelope
encrypted_master_key=$(echo "$master_key" | openssl smime -encrypt -aes-256-cbc -outform DER <(echo "$server_cert") | base64 -w 0)

# Check if the openssl smime command was successful
if [ $? -ne 0 ]; then
  handle_error "Failed to encrypt master key using S/MIME (PKCS#7) envelope." 4
fi

# Send the encrypted master key and sample message to the server
KEY_EXCHANGE='{"sessionID": "'$session_id'", "masterKey": "'$encrypted_master_key'", "sampleMessage": "Hi server, please encrypt me and send to client!"}'
#Send the encripted master key
response=$(curl -s -X POST -H "Content-Type: application/json" -d "$KEY_EXCHANGE" http://47.128.239.41:8080/keyexchange)
echo "Key Exchange Response: $response"

# Parse the key exchange response using jq
encrypted_sample_message=$(echo "$response" | jq -r '.encryptedSampleMessage')

# Check if the extracted value is empty
if [ -z "$encrypted_sample_message" ]; then
  echo "Step 6 failed: Unable to parse Encrypted Sample Message from key exchange response."
  echo "Actual Key Exchange Response: $response"
  exit 6
fi

# Step 6 - Client verification message
echo "Encrypted Sample Message: $encrypted_sample_message"
# Print the content of the file for debugging
cat encSampleMsgReady.txt

# Save the encrypted sample message to a file for inspection
echo "$encrypted_sample_message" | base64 -d > encSampleMsgReady.txt

# Decrypt the sample message using the master key
DECRYPTED_SAMPLE_MESSAGE=$(openssl enc -d -aes-256-cbc -pbkdf2 -in encSampleMsgReady.txt -pass pass:"$master_key")

# Print intermediate values for debugging
echo "Encrypted Sample Message (Base64): $encrypted_sample_message"
echo "Decrypted Sample Message: $DECRYPTED_SAMPLE_MESSAGE"

# Step 7 - Server verification
if [ "$DECRYPTED_SAMPLE_MESSAGE" != "Hi server, please encrypt me and send to client!" ]; then
    echo "Error: Server symmetric encryption using the exchanged master-key has failed."
    exit 6
fi
echo "Decrypted Sample Message on the server: $DECRYPTED_SAMPLE_MESSAGE"
echo "Client-Server TLS handshake has been completed successfully."
echo "Well Done! You’ve manually implemented secure communication over HTTP!"