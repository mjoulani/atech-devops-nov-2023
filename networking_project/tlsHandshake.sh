#!/bin/bash
json_data=$(curl -X POST -H "Content-Type: application/json" -d '{
  "version": "1.3",
  "ciphersSuites": [
    "TLS_AES_128_GCM_SHA256",
    "TLS_CHACHA20_POLY1305_SHA256"
  ],
  "message": "Client Hello"
}' http://18.180.54.40:8080/clienthello)

version=$(echo "$json_data" | jq -r '.version')
sessionID=$(echo "$json_data" | jq -r '.sessionID')
cipherSuite=$(echo "$json_data" | jq -r '.cipherSuite')
serverCert=$(echo "$json_data" | jq -r '.serverCert')

echo $version
echo $sessionID
echo $cipherSuite
echo "$serverCert"
echo "$serverCert" > serverCert.pem

test="$(openssl verify -CAfile cert-ca-aws.pem serverCert.pem)"

#test="$(openssl verify -CAfile cert-ca-aws.pem serverCert.pem)"
if [ "$test" == "serverCert.pem: OK" ]; then
    #echo $test
    echo "OK"
else
    #echo $test
    echo "Server Certificate is invalid."
    echo "Try again"
    exit 5
fi


MASTER_KEY=$(openssl rand -base64 32)
echo "$MASTER_KEY" > master-key

ENCRYPTED_MASTER_KEY=$(openssl smime -encrypt -aes-256-cbc -in master-key  -outform DER serverCert.pem | base64 -w 0)



#json_data1=$(curl -X POST -H "Content-Type: application/json" -d '{
    #"sessionID": "'"$sessionID"'",
    #"masterKey": "'"$ENCRYPTED_MASTER_KEY"'",
    #"sampleMessage": "Hi server, please encrypt me and send to client!"
#} 'http://18.180.54.40:8080/keyexchange)

KEY_EXCHANGE='{
    "sessionID": "'"$sessionID"'",
    "masterKey": "'"$ENCRYPTED_MASTER_KEY"'",
    "sampleMessage": "Hi server, please encrypt me and send to client!"
}'
json_data1=$(curl -s -X POST -H "Content-Type: application/json" -d "$KEY_EXCHANGE" http://18.180.54.40:8080/keyexchange)


# Check if the curl command was successful
if [ $? -eq 0 ]; then
    echo "cURL request successful"
else
    echo "cURL request failed"
    exit 1
fi

sessionID=$(echo "$json_data1" | jq -r '.sessionID')
encryptedSampleMessage=$(echo "$json_data1" | jq -r ".encryptedSampleMessage")



echo "$encryptedSampleMessage" > txt1
echo "$encryptedSampleMessage" | base64 -d > encSampleMsgReady.txt
#file encSampleMsgReady.txt is ready now to be used in "openssl enc...." command


DECRYPTED_SAMPLE_MESSAGE=$(openssl smime -decrypt -aes-256-cbc -inform DER -in encSampleMsgReady.txt  master-key 2>/dev/null)
#DECRYPTED_SAMPLE_MESSAGE=$(openssl smime -decrypt -in encSampleMsgReady.txt -inform DER  master-key)
#DECRYPTED_SAMPLE_MESSAGE=$(openssl smime -decrypt -inform DER -in encSampleMsgReady.txt  ~master-key)

# Check if the decryption was successful
if [ $? -ne 0 ]; then
    echo "Server symmetric encryption using the exchanged master-key has failed."
    exit 6
fi

# Output decrypted message
echo "Decrypted Sample Message: $DECRYPTED_SAMPLE_MESSAGE"

# Print positive message upon successful TLS handshake completion
echo "Client-Server TLS handshake has been completed successfully"





