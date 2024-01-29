#!/bin/bash

public_ip=$1
usage() {
  echo "tlsHandShake.sh [ip]"
  exit 6
}

failed() {
  echo "Server symmetric encryption using the exchanged master-key has fail>  exit 6
}

success() {
  echo "Client-Server TLS handshake has been completed successfully"
  exit 0
}
check_if_server_and_send_hello() {
  curl $public_ip:8080/status
  if [[ $? -ne 0 ]]; then
    echo "Server is not online"
    exit 1
  fi

  echo "Beginning TLS with hello client .."
  response=$(curl -X POST -d '{
    "version": "1.3",
    "ciphersSuites": ["TLS_AES_128_GCM_SHA256", "TLS_CHACHA20_POLY1305_SHA2>    "message": "Client Hello"
  }' $public_ip:8080/clienthello -H 'Content-Type: application/json' 2> /de>  SESSION_ID=$(echo $response | jq -r .sessionID)
}
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
    echo "Please provide the server's IP address."
    usage
  fi

  check_if_server_and_send_hello

  echo "Validating Certificate ..."
  validate_cert_and_generate_key

  echo "Encrypting master key with certificate"
  MASTER_KEY=$(encryptMasterKey)

  echo "Sending Key ..."
  response=$(send_key 2> /dev/null)

  echo "Decrypting message.."
  decrypt

  if [[ $(cat decrypted.txt) == "Hi server, please encrypt me and send to c>    cat decrypted.txt
    success
  else
    failed
  fi
}

main
