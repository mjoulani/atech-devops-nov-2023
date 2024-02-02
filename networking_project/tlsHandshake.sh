#!/bin/bash

# Define server URL and paths for keys and certificates
server_url="http://0.0.0.0:8080"
client_hello_endpoint="$server_url/clienthello"
key_exchange_endpoint="$server_url/keyexchange"
ca_certificate_url="https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem"
ca_certificate_path="ca-cert.pem"
client_private_key="client_key.pem"
client_public_key="client_key.pub"

# Step 1: Client Hello
echo "Initiating Client Hello..."
response=$(curl -s -X POST -H "Content-Type: application/json" -d '{
    "message": "Client Hello",
    "tlsVersion": "TLSv1.3",
    "preferredCiphers": ["TLS_AES_256_GCM_SHA384", "TLS_CHACHA20_POLY1305_SHA256"]
}' $client_hello_endpoint)

# Extract server response
server_tls_version=$(echo $response | jq -r '.tlsVersion')
cipher_chosen=$(echo $response | jq -r '.chosenCipher')
server_session_id=$(echo $response | jq -r '.sessionId')
server_public_key=$(echo $response | jq -r '.serverPublicKey')

echo "Server TLS Version: $server_tls_version, Cipher: $cipher_chosen, Session ID: $server_session_id"

# Step 2: Verify Server Certificate
echo "Downloading CA certificate..."
wget -q $ca_certificate_url -O $ca_certificate_path

echo "Verifying server certificate..."
echo $server_public_key | openssl verify -CAfile $ca_certificate_path > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Server Certificate verification failed."
    exit 1
fi

# Step 3: Key Exchange
echo "Generating and encrypting master key for key exchange..."
master_key=$(openssl rand -base64 32)
echo $server_public_key | openssl rsautl -encrypt -inkey <(echo "$server_public_key") -pubin | base64 > encrypted_master_key.txt

encrypted_key=$(cat encrypted_master_key.txt)

key_exchange_response=$(curl -s -X POST -H "Content-Type: application/json" -d '{
    "sessionId": "'$server_session_id'",
    "encryptedKey": "'$encrypted_key'",
    "message": "Encrypted key exchange message"
}' $key_exchange_endpoint)

echo "Key exchange response: $key_exchange_response"

# Step 4: Final Verification
encrypted_message=$(echo $key_exchange_response | jq -r '.encryptedMessage')
echo $encrypted_message | base64 -d | openssl enc -d -aes-256-cbc -k $master_key > decrypted_message.txt

decrypted_message=$(cat decrypted_message.txt)
expected_message="Encrypted key exchange message"

if [ "$decrypted_message" != "$expected_message" ]; then
    echo "Message decryption failed or message content mismatch."
    exit 2
fi

echo "TLS-like secure communication established successfully."
