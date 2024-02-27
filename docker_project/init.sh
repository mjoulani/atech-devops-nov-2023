#!/bin/bash

# Absolute path to ngrok executable
# NGROK_PATH="C:/Users/User/Desktop/DevOps/ngrok"

# Start ngrok to expose a local server (replace 8443 with your desired port)
ngrok http 8443 > ngrok_output.log 2>&1 &

# Wait for a few seconds to allow ngrok to start (adjust as needed)
echo "Please wait ...."
sleep 5
# Run curl command to retrieve JSON data from ngrok
json_data=$(curl -s -g -X GET "http://localhost:4040/api/tunnels")
public_url=$(echo "$json_data" | jq -r '.tunnels[0].public_url')

# Print the public URL
export PUBLIC_IP=$public_url
echo $PUBLIC_IP
