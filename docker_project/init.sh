#!/bin/bash

# Check if the first argument is "down"
if [ "$1" = "down" ]; then

    # Stop Docker containers using docker-compose
    echo "Stopping Docker containers..."
    docker-compose down

else
    # Start ngrok to expose a local server (replace 8443 with your desired port)
    ngrok http 8443 > ngrok_output.log 2>&1 &

    # Wait for a few seconds to allow ngrok to start (adjust as needed)
    echo "Running ngrok ..."

    sleep 5
    # Run curl command to retrieve JSON data from ngrok
    json_data=$(curl -s -g -X GET "http://localhost:4040/api/tunnels")
    echo "Getting app ip ..."
    public_url=$(echo "$json_data" | jq -r '.tunnels[0].public_url')

    export PUBLIC_IP=$public_url
    export TELE_TOKEN=$(cat bot_tokens.pem)
    export PICTURES_TOKEN=$(cat pixabay_token.pem)



    echo "Running Docker containers..."
    running=$(docker compose up -d)

fi
