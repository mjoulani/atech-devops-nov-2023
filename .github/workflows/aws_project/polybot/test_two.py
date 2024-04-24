import requests
import urllib3
urllib3.disable_warnings()

# Your Telegram bot token
TELEGRAM_TOKEN = '6671531875:AAG0nnI0XX_kneDgsOXNfclJi0V0tpuGwBU'

# Your webhook URL
WEBHOOK_URL = 'https://muh-aws-alb-1133477302.us-west-1.elb.amazonaws.com/6671531875:AAG0nnI0XX_kneDgsOXNfclJi0V0tpuGwBU/'

# Replace 'YOUR_CHAT_ID' with your actual chat ID
CHAT_ID = '6726434078c'

def set_webhook():
    url = f'https://api.telegram.org/bot{TELEGRAM_TOKEN}/setWebhook'
    certificate_path = 'certificate.pem'
    files = {'url': WEBHOOK_URL, 'certificate': open(certificate_path, 'rb')}
    response = requests.post(url, files=files, verify=False)
    if response.status_code == 200:
        print("Webhook set up successfully.")
    else:
        print("Failed to set up webhook. Status code:", response.status_code)

def send_test_message():
    message = "Hello muhamed good job"
    # Send a message to the bot using the sendMessage method
    url = f'https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage'
    payload = {'chat_id': CHAT_ID, 'text': message}
    response = requests.post(url, json=payload, verify=False)

    # Check if the message was sent successfully
    if response.status_code == 200:
        print("Message sent successfully!")
    else:
        print("Failed to send message. Status code:", response.status_code)

def main():
    # Set up the bot webhook
    print("Setting up bot webhook...")
    set_webhook()

    # Send a test message to the bot
    send_test_message()

if __name__ == "__main__":
    main()









