import requests
from flask import Flask, request, jsonify

app = Flask(__name__)

ngrok_url = 'https://0775-89-139-74-229.ngrok-free.app'
TELEGRAM_BOT_TOKEN = '6671531875:AAG0nnI0XX_kneDgsOXNfclJi0V0tpuGwBU'
TELEGRAM_CHAT_ID = '6726434078'

def test_ngrok_connection():
    try:
        response = requests.get(ngrok_url, verify=True)  # Disable SSL certificate verification for ngrok
        if response.status_code == 200:
            print("Connection to Ngrok successful")
        else:
            print("Failed to connect to Ngrok. Status code:", response.status_code)
    except requests.RequestException as e:
        print("Failed to connect to Ngrok:", e)

def send_telegram_message(message):
    try:
        url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
        payload = {
            "chat_id": TELEGRAM_CHAT_ID,
            "text": message
        }
        response = requests.post(url, json=payload)
        if response.status_code == 200:
            print("Telegram message sent successfully")
        else:
            print("Failed to send Telegram message. Status code:", response.status_code)
    except requests.RequestException as e:
        print("Failed to send Telegram message:", e)

def listen_for_telegram_messages():
    # Implement code to listen for incoming messages from Telegram
    # Example:
    # while True:
    #     updates = get_updates_from_telegram()
    #     for update in updates:
    #         process_update(update)
    #     time.sleep(1)
    pass

@app.route(f'/{TELEGRAM_BOT_TOKEN}', methods=['POST'])
def webhook():
    update = request.json
    if 'message' in update:
        message = update['message']
        chat_id = message['chat']['id']
        text = message['text']
        print(f"Received message from chat {chat_id}: {text}")
        # Process the incoming message as needed
        # For example, you can send a response back to the user
        send_telegram_message(f"Received your message: {text}")
    return jsonify({'status': 'ok'})

if __name__ == "__main__":
    test_ngrok_connection()
    send_telegram_message("Hello from the bot!")  # Send a message first
    listen_for_telegram_messages()  # Wait for incoming messages
    app.run(debug=True, host='0.0.0.0', port=8443)
