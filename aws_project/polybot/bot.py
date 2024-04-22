import json

import telebot
from loguru import logger
import os
import time
from telebot.types import InputFile
import boto3

class Bot:

    def __init__(self, token, telegram_chat_url, s3_bucket_name, sqs_queue_name):
        # create a new instance of the TeleBot class.
        # all communication with Telegram servers are done using self.telegram_bot_client
        print(token)
        print(telegram_chat_url)
        print(s3_bucket_name)
        print(sqs_queue_name)

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

    def is_current_msg_photo(self, msg):
        return 'photo' in msg

    def download_user_photo(self, msg):
        """
        Downloads the photos that sent to the Bot to `photos` directory (should be existed)
        :return:
        """
        if not self.is_current_msg_photo(msg):
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
        self.send_text(msg['chat']['id'], f'Your original message: {msg["text"]}')


class ObjectDetectionBot(Bot):
    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')

        if self.is_current_msg_photo(msg):
            photo_path = self.download_user_photo(msg)

            def __init__(self, token, telegram_chat_url, s3_bucket_name, sqs_queue_name):
                super().__init__(token, telegram_chat_url)
                self.s3_bucket_name = s3_bucket_name
                self.sqs_queue_name = sqs_queue_name
                self.sqs_client = boto3.client('sqs')
                self.s3_client = boto3.client('s3')

            # TODO upload the photo to S3
            photo_key = os.path.basename(photo_path)
            self.s3_client.upload_file(photo_path, self.s3_bucket_name, photo_key)
            logger.info(f'Uploaded photo to S3: {photo_key}')

            # TODO send a job to the SQS queue
            # Send a job to the SQS queue
            sqs_message = {
                'chat_id': msg['chat']['id'],
                'img_name': photo_key
            }
            sqs_response = self.sqs_client.send_message(
                QueueUrl=self.sqs_queue_name,
                MessageBody=json.dumps(sqs_message)
            )
            # TODO send message to the Telegram end-user (e.g. Your image is being processed. Please wait...)
            self.send_text(msg['chat']['id'], 'Your image is being processed. Please wait...')

