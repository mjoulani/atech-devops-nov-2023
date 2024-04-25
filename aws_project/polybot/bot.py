import boto3
import telebot
from loguru import logger
import os
import time
from telebot.types import InputFile


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
    def __init__(self, token, telegram_chat_url):
        super().__init__(token, telegram_chat_url)
        self.s3_client = boto3.client('s3')
        self.sqs_client = boto3.client('sqs', region_name='ap-northeast-1')
        self.queue_url = 'https://sqs.ap-northeast-1.amazonaws.com/933060838752/abedallahjo-polybot-sqs'
        """
        self.telegram_bot_client.set_webhook(..., certificate=open(CERTIFICATE_FILE_NAME, 'r')))
        """

    def upload_photo_to_s3(self, photo_path):
        self.s3_client.upload_file(photo_path, 'abedallah-joulany-bucket', f'{photo_path}')
        logger.info(f'Uploaded photo to S3: {photo_path}')

    def send_results_to_user(self, chat_id, results):
        # Format the results into a user-friendly message
        formatted_results = "Here are the detected objects:\n"
        for object_name, confidence in results.items():
            formatted_results += f"- {object_name} (confidence: {confidence:.2f})\n"
        self.send_text(chat_id, formatted_results)

    def send_job_to_sqs(self, photo_path):
        with open(photo_path, 'rb') as photo:
            photo_data = photo.read()

        response = self.sqs_client.send_message(
            QueueUrl=self.queue_url,
            MessageBody=photo_data.decode('utf-8')
        )
        logger.info(f'Sent job to SQS: {response["MessageId"]}')

    def send_results_to_user(self, chat_id, results):
        # Format the results into a user-friendly message
        formatted_results = "Here are the detected objects:\n"
        for object_name, confidence in results.items():
            formatted_results += f"- {object_name} (confidence: {confidence:.2f})\n"
        self.send_text(chat_id, formatted_results)

    def handle_message(self, msg):
        logger.info(f'Incoming message: {msg}')

        if self.is_current_msg_photo(msg):
            # TODO upload the photo to S3
            photo_path = self.download_user_photo(msg)
            self.upload_photo_to_s3(photo_path)
            # TODO send a job to the SQS queue
            # prediction_results = self.get_object_detection_predictions(photo_path)

            # TODO send message to the Telegram end-user (e.g. Your image is being processed. Please wait...)
            # self.send_results_to_user(msg['chat']['id'], prediction_results)
            self.send_job_to_sqs(photo_path)
            self.send_text(msg['chat']['id'], 'Your image is being processed. Please wait...')

