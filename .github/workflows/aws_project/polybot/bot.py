import telebot
from loguru import logger
import os
import time
from telebot.types import InputFile
from collections import Counter
import boto3
import requests

class Bot:
    def __init__(self, token, telegram_chat_url):
        self.telegram_bot_client = telebot.TeleBot(token)
        self.telegram_bot_client.remove_webhook()
        time.sleep(0.5)
        
        # Construct the webhook URL without /webhook at the end
        webhook_url = f'{telegram_chat_url}/{token}'
        
        # Path to the certificate file
        cert_path = 'C:\\atech-devops-nov-2023\\.github\\workflows\\aws_project\\polybot\\cert.pem'
        
        # URL for Telegram Bot API to set the webhook
        telegram_bot_api_url = f'https://api.telegram.org/bot{token}/setWebhook'
        
        # Send a POST request to set the webhook
        response = requests.post(telegram_bot_api_url, files={'url': webhook_url, 'certificate': open(cert_path, 'rb')})
        
        # Check if the request was successful
        if response.ok:
            logger.info("Webhook successfully set via API.")
        else:
            logger.error(f"Failed to set webhook via API. Response: {response.text}")

    def send_text(self, chat_id, text):
        self.telegram_bot_client.send_message(chat_id, text)

    def send_text_with_quote(self, chat_id, text, quoted_msg_id):
        # Implement this method to send a message with a quote
        pass

    @staticmethod
    def is_current_msg_photo(msg):
        return 'photo' in msg

    def download_user_photo(self, msg):
        if not self.is_current_msg_photo(msg):
            text ="Hi upload photo please"
            self.send_text(msg['chat']['id'], text)
            raise RuntimeError(f'Message content of type \'photo\' expected')

        file_info = self.telegram_bot_client.get_file(msg['photo'][-1]['file_id'])
        data = self.telegram_bot_client.download_file(file_info.file_path)
        folder_name = file_info.file_path.split('/')[0]

        if not os.path.exists(folder_name):
            os.makedirs(folder_name)

        with open(file_info.file_path, 'wb') as photo:
            photo.write(data)

        return file_info.file_path

    def send_photo(self, chat_id, img_path):
        if not os.path.exists(img_path):
            raise RuntimeError("Image path doesn't exist")

        self.telegram_bot_client.send_photo(
            chat_id,
            InputFile(img_path)
        )

    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')
        self.send_text(msg['chat']['id'], f'Your original message: {msg["text"]}')

class QuoteBot(Bot):
    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')

        if msg["text"] != 'Please don\'t quote me':
            self.send_text_with_quote(msg['chat']['id'], msg["text"], quoted_msg_id=msg["message_id"])

class ObjectDetectionBot(Bot):
    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')
        img_path = self.download_user_photo(msg)
        logger.info(f'Downloaded photo to {img_path}')

        s3 = boto3.client('s3')
        bucket_name = 'mjoulani-bucket'

        s3.upload_file(img_path, bucket_name, os.path.basename(img_path))

        logger.info(f'The image is uploaded to {bucket_name}')