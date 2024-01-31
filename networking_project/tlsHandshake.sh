#!/bin/bash
# Initialize a secure communication session with the server and perform a key exchange
SERVER_URL="http://18.180.54.40:8080"
CLIENT_HELLO_ENDPOINT="${SERVER_URL}/clienthello"
KEY_EXCHANGE_ENDPOINT="${SERVER_URL}/keyexchange"

# Sending Client Hello message to initiate the TLS handshake
client_hello_response=$(curl -s -X POST -H "Content-Type: application/json" -d '{
    "version": "1.3",
    "ciphersSuites": [
        "TLS_AES_128_GCM_SHA256",
        "TLS_CHACHA20_POLY1305_SHA256"
    ],
    "message": "Client Hello"
}' "${CLIENT_HELLO_ENDPOINT}")

# Extracting necessary details from the response
version=$(echo "$client_hello_response" | jq -r '.version')
session_id=$(echo "$client_hello_response" | jq -r '.sessionID')
selected_cipher=$(echo "$client_hello_response" | jq -r '.cipherSuite')
server_certificate=$(echo "$client_hello_response" | jq -r '.serverCert')

# Displaying the extracted details
echo "TLS Version: $version"
echo "Session ID: $session_id"
echo "Selected Cipher Suite: $selected_cipher"
echo -e "Server Certificate:\n$server_certificate"

# Saving the server certificate for verification
echo "$server_certificate" > serverCert.pem

# Verifying the server certificate against a known CA certificate
certificate_verification=$(openssl verify -CAfile cert-ca-aws.pem serverCert.pem)
if [ "$certificate_verification" == "serverCert.pem: OK" ]; then
    echo "Certificate verification successful"
else
    echo "Error: Server Certificate is invalid."
    exit 5
fi

# Generating a master key for encryption
master_key=$(openssl rand -base64 32)
echo "$master_key" > master-key

# Encrypting the master key using the server's public certificate
encrypted_master_key=$(openssl smime -encrypt -aes-256-cbc -in master-key -outform DER serverCert.pem | base64 -w 0)

# Preparing and sending the key exchange request
key_exchange_data='{
    "sessionID": "'"${session_id}"'",
    "masterKey": "'"${encrypted_master_key}"'",
    "sampleMessage": "Hi server, please encrypt me and send to client!"
}'
key_exchange_response=$(curl -s -X POST -H "Content-Type: application/json" -d "$key_exchange_data" "${KEY_EXCHANGE_ENDPOINT}")

# Checking the response status
if [ $? -eq 0 ]; then
    echo "Key exchange request sent successfully"
else
    echo "Error: Key exchange request failed"
    exit 1
fi

# Extracting encrypted sample message
encrypted_sample_message=$(echo "$key_exchange_response" | jq -r ".encryptedSampleMessage")
echo "$encrypted_sample_message" | base64 -d > encrypted_sample_message.txt

# Decrypting the sample message using the master key
decrypted_message=$(openssl smime -decrypt -aes-256-cbc -inform DER -in encrypted_sample_message.txt -inkey master-key 2>/dev/null)

# Check for decryption success
if [ $? -ne 0 ]; then
    echo "Error: Decryption failed."
    exit 6
fi

# Displaying the decrypted message
echo "Decrypted Sample Message: $decrypted_message"

# Success message
echo "TLS handshake and secure communication setup completed successfully."
