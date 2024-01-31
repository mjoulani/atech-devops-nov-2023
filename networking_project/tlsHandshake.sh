#!/bin/bash

public_ip=$1
usage() {
  echo "tlsHandShake.sh [ip]"
  exit 6
}
failed() {
  echo "Server symmetric encryption using the exchanged master-key has fail"  exit 6
}
success() {
  echo "Client-Server TLS handshake has been completed successfully"
  exit 0
}
check_if_server_and_send_hello() {
  curl "$public_ip":8080/status
  if [[ $? -ne 0 ]]; then
    echo "Server is not online"
    exit 1
  fi
}
public_ip="your_server_ip"

echo "Beginning TLS with hello client"
response=$(curl -X POST -d '{
    "version": "1.3",
    "ciphersSuites": ["TLS_AES_128_GCM_SHA256", "TLS_CHACHA20_POLY1305_SHA256"],
    "message": "Client Hello"
}' http://$public_ip:8080/clienthello -H 'Content-Type: application/json' 2>/dev/null)

# Check if curl command was successful (HTTP status code 2xx)
if [ $? -eq 0 ]; then
    # Check if the response contains a sessionID using jq
    if [ -n "$response" ] && [ "$(echo $response | jq -e '.sessionID')" != "null" ]; then
        SESSION_ID=$(echo $response | jq -r .sessionID)
        echo "Session ID: $SESSION_ID"
    else
        echo "Error: Unable to extract sessionID from the response."
    fi
else
    echo "Error: Curl command failed."
fi

validate_cert_and_generate_key() {
  openssl verify -CAfile cert-ca-aws.pem cert.pem 2> /dev/null
  if [[ $? -ne 0 ]]; then
    echo "Server Certificate is invalid."
    exit 5
  fi

  echo "Generating Master Key"
  openssl rand 32 | base64 > master_key
}
main() {
  if [[ -z $public_ip ]]; then
    echo "Please provide the servers IP address."
    usage
  fi

  check_if_server_and_send_hello

  echo "falidating Certificate "
  validate_cert_and_generate_key

  echo "Encrypting master key with certificate"
  MASTER_KEY=$(encryptMasterKey)

  echo "Sending Key"
  response=$(send_key 2> /dev/null)

  echo "Decrypting message"
  decrypt

if [[ $(cat decrypted.txt) == "Hi server, please encrypt me and send to client" ]]; then
    echo "success"
else
    echo "failed"
fi
}main
