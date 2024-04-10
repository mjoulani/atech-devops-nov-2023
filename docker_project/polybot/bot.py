import telebot
from loguru import logger
import os
import time
from telebot.types import InputFile
import boto3
import requests

class Bot:

    def __init__(self, token, telegram_chat_url):
        # create a new instance of the TeleBot class.
        # all communication with Telegram servers are done using self.telegram_bot_client
        self.telegram_bot_client = telebot.TeleBot(token)

        # remove any existing webhooks configured in Telegram servers
        self.telegram_bot_client.remove_webhook()
        time.sleep(0.5)

        # set the webhook URL
        self.telegram_bot_client.set_webhook(url=f'{telegram_chat_url}/{token}/', timeout=60)

        logger.info(f'Telegram Bot information\n\n{self.telegram_bot_client.get_me()}')

    def send_text(self, chat_id, text):
        self.telegram_bot_client.send_message(chat_id, text)

    def send_text_with_quote(self, chat_id, text, quoted_msg_id):
        self.telegram_bot_client.send_message(chat_id, text, reply_to_message_id=quoted_msg_id)

    @staticmethod
    def is_current_msg_photo(msg):
        return 'photo' in msg

    def download_user_photo(self, msg):
        """
        Downloads the photos that sent to the Bot to `photos` directory (should be existed)
        :return:
        """
        if not self.is_current_msg_photo(msg):
            #text = "Provide Only photos"
            #self.send_text(msg['chat']['id'], text)
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
        """Bot Main message handler"""
        logger.info(f'Incoming message: {msg}')
        self.send_text(msg['chat']['id'], f'Your original message: {msg}')
class QuoteBot(Bot):
    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')

        if msg["text"] != 'Please don\'t quote me':
            self.send_text_with_quote(msg['chat']['id'], msg["text"], quoted_msg_id=msg["message_id"])


class ObjectDetectionBot(Bot):
    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')

        if 'photo' in msg:
            self.handle_photo_message(msg)  # Call photo-specific handling method
        else:
            super().handle_message(msg)  # Call parent class's handling method for other cases
        #if 'text' in msg:
            #self.handle_text_message(msg)
        #elif self.is_current_msg_photo(msg):
            #self.handle_photo_message(msg)
        #if self.is_current_msg_photo(msg):
            #self.handle_photo_message(msg)
        #else:
            #self.handle_text_message(msg)
        #if self.is_current_msg_photo(msg):
            #pass
    def handle_photo_message(self, msg):
        # TODO download the user photo (utilize download_user_photo)
        photo_file = self.download_user_photo(msg)
        # TODO upload the photo to S3
        bucket_name = os.environ['BUCKET_NAME']
        s3_key = f'photos/{photo_file}'
        s3 = boto3.client('s3')
        s3.upload_file(photo_file, bucket_name, s3_key)
        #upload_to_s3(photo_file, bucket_name, s3_key)
        # TODO send a request to the `yolo5` service for prediction
        yolo5_service_url = 'localhost:8081/predict'
        payload = {'photo_key': s3_key}
        response = requests.post(yolo5_service_url, json=payload)
        prediction_results = response.json()
        # TODO send results to the Telegram end-user
        self.send_text(msg['chat']['id'], f'Prediction results: {prediction_results}')
        #self.send_message(prediction_results)
    def handle_text_message(self, msg):
        self.send_text(msg['chat']['id'], f'Your original message: {msg.get("text", "No text message")}')
        #def upload_to_s3(photo_file, bucket_name, s3_key):
            #s3 = boto3.client('s3')
            #s3.upload_file(photo_file, bucket_name, s3_key)
