#!/bin/bash

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Check if public instance IP address is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <public-ec2-instance-ip>"
    exit 1
fi

public_instance_ip="$1"
log "Public instance IP address: $public_instance_ip"

# Step 1 - Client Hello
log "Sending Client Hello..."
client_hello_response=$(curl -s -X POST -H "Content-Type: application/json" -d '{"version":"1.3","ciphersSuites":["TLS_AES_128_GCM_SHA256","TLS_CHACHA20_POLY1305_SHA256"],"message":"Client Hello"}' http://$public_instance_ip:8080/clienthello)

# Parse JSON response
version=$(echo "$client_hello_response" | jq -r '.version')
cipher_suite=$(echo "$client_hello_response" | jq -r '.cipherSuite')
session_id=$(echo "$client_hello_response" | jq -r '.sessionID')
server_cert=$(echo "$client_hello_response" | jq -r '.serverCert' | sed 's/\\n/\'$'\n''/g')

log "Client Hello successful. Server version: $version, Cipher suite: $cipher_suite"

# Step 2 - Server Certificate Verification
log "Verifying server certificate..."
wget -q https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem -O cert-ca-aws.pem
ca_file="cert-ca-aws.pem"

echo "$server_cert" > server_cert.pem

verification_result=$(openssl verify -CAfile "$ca_file" -verbose server_cert.pem 2>&1)

if echo "$verification_result" | grep -q "OK"; then
    log "Server Certificate is valid."
else
    log "Server Certificate is invalid."
    exit 5
fi

# Step 3 - Client-Server Master Key Exchange
log "Generating master key..."
# Generate a random 256-bit key (32 bytes) using OpenSSL
master_key=$(openssl rand -base64 32 > key_master.txt)

if ![ -z "$master_key" ]; then
   log "Failed to generate the master key."
    exit 7
fi

log "Master key generated successfully."

# Encrypt master key with a password
#encrypted_master_key=$(echo "$master_key" | openssl enc -aes-256-cbc -a -salt -pbkdf2 -pass pass:mypasswd)
encrypted_master_key=$(openssl smime -encrypt -aes-256-cbc -in key_master.txt -outform DER server_cert.pem | base64 -w 0)

# Step 4 - Server Verification Message
log "Sending master key to server for verification..."
key_exchange_response=$(curl -s -X POST -H "Content-Type: application/json" -d '{"sessionID":"'$session_id'","masterKey":"'$encrypted_master_key'","sampleMessage":"Hi server, please encrypt me and send to client!"}' http://$public_instance_ip:8080/keyexchange)
 log "this is the response from the curl request for the exchange: $key_exchange_response"
# Parse JSON response
encrypted_sample_message=$(echo "$key_exchange_response" | jq -r '.encryptedSampleMessage')
echo $encrypted_sample_message | base64 -d > encSampleMsgReady.txt

log "Master key sent. Encrypted sample message received from server."


# Step 5 - Client Verification Message
log "Decrypting sample message from server..."
# Decrypt sample message from server using password
log "sessionID:$session_id,masterKey:$encrypted_master_key"
log "This is the encrypted sample message: $encrypted_sample_message"

#decrypted_message=$(echo "$encrypted_sample_message" | openssl aes-256-cbc -d -a --pbkdf2 pass "pass:$master_key" 2>&1)
#decrypted_message=$(echo "$encrypted_sample_message" | openssl aes-256-cbc -d -pass "pass:$master_key" -pbkdf2 2>&1)
decrypted_message=$(openssl enc --aes-256-cbc -d -in encSampleMsgReady.txt -kfile key_master.txt -pbkdf2)
log "This is the decrypted sample message: $decrypted_message"

if [ "$(echo "$decrypted_message" | grep -c 'bad decrypt')" -gt 0 ]; then
    log "Error: Bad decrypt."
    exit 6
fi

expected_message="Hi server, please encrypt me and send to client!"

if [ "$decrypted_message" != "$expected_message" ]; then
    log "Decryption does not match expected message."
    exit 6
fi

log "Decryption successful. Client-Server TLS handshake has been completed."

# Clean up
# Clean up
log "Cleaning up temporary files..."
rm -f cert-ca-aws.pem server_cert.pem master_key.bin encrypted_master_key.bin

log "Script execution completed."
